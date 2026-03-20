// RUN: rm -rf %t && mkdir -p %t
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadConversion -fdisable-module-hash -fapinotes-modules -fsyntax-only -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -x c++
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadConversion -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter 'OverloadConversion::operator int' -x c++ | FileCheck --check-prefix=CHECK-INT %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadConversion -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter 'OverloadConversion::operator double' -x c++ | FileCheck --check-prefix=CHECK-DOUBLE %s

#include "OverloadConversion.h"

// CHECK-INT: Dumping OverloadConversion::operator int:
// CHECK-INT-NEXT: CXXConversionDecl {{.+}} operator int
// CHECK-INT-NOT: UnavailableAttr
// CHECK-INT-NOT: int conversion unavailable

// CHECK-DOUBLE: Dumping OverloadConversion::operator double:
// CHECK-DOUBLE-NEXT: CXXConversionDecl {{.+}} operator double
// CHECK-DOUBLE-NOT: UnavailableAttr
// CHECK-DOUBLE-NOT: double conversion unavailable
