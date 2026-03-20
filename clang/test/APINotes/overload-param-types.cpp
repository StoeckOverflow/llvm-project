// RUN: rm -rf %t && mkdir -p %t
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadParamTypes -fdisable-module-hash -fapinotes-modules -fsyntax-only -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -x c++
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/OverloadParamTypes -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter OverloadParamTypes::frob -x c++ | FileCheck --check-prefix=CHECK %s

#include "OverloadParamTypes.h"

// CHECK: Dumping OverloadParamTypes::frob:
// CHECK-NEXT: CXXMethodDecl {{.+}} frob 'void (int)'
// CHECK-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK: UnavailableAttr {{.+}} <<invalid sloc>> "int overload unavailable"
// CHECK-NOT: "double overload unavailable"
// CHECK: Dumping OverloadParamTypes::frob:
// CHECK-NEXT: CXXMethodDecl {{.+}} frob 'void (double)'
// CHECK-NEXT: ParmVarDecl {{.+}} 'double'
// CHECK: UnavailableAttr {{.+}} <<invalid sloc>> "double overload unavailable"
// CHECK-NOT: "int overload unavailable"
