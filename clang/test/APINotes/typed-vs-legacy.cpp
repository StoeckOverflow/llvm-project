// RUN: rm -rf %t && mkdir -p %t
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -fsyntax-only -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -x c++
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::mix -x c++ | FileCheck --check-prefix=CHECK-MIX %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::ping -x c++ | FileCheck --check-prefix=CHECK-PING %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::selfOnly -x c++ | FileCheck --check-prefix=CHECK-SELF %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::rewrite -x c++ | FileCheck --check-prefix=CHECK-REWRITE %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::partial -x c++ | FileCheck --check-prefix=CHECK-PARTIAL %s
// RUN: %clang_cc1 -fmodules -fblocks -fimplicit-module-maps -fmodules-cache-path=%t/ModulesCache/TypedVsLegacy -fdisable-module-hash -fapinotes-modules -I %S/Inputs/Headers -F %S/Inputs/Frameworks %s -ast-dump -ast-dump-filter TypedVsLegacy::singleZeroTyped -x c++ | FileCheck --check-prefix=CHECK-SINGLE %s

#include "TypedVsLegacy.h"

// CHECK-MIX: Dumping TypedVsLegacy::mix:
// CHECK-MIX-NEXT: CXXMethodDecl {{.+}} mix 'void (int)'
// CHECK-MIX-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-MIX: UnavailableAttr {{.+}} <<invalid sloc>> "int mix unavailable"
// CHECK-MIX-NOT: "legacy mix unavailable"
// CHECK-MIX: Dumping TypedVsLegacy::mix:
// CHECK-MIX-NEXT: CXXMethodDecl {{.+}} mix 'void (double)'
// CHECK-MIX-NEXT: ParmVarDecl {{.+}} 'double'
// CHECK-MIX: UnavailableAttr {{.+}} <<invalid sloc>> "legacy mix unavailable"
// CHECK-MIX-NOT: "int mix unavailable"

// CHECK-PING: Dumping TypedVsLegacy::ping:
// CHECK-PING-NEXT: CXXMethodDecl {{.+}} ping 'void ()'
// CHECK-PING: UnavailableAttr {{.+}} <<invalid sloc>> "zero-arg ping unavailable"
// CHECK-PING-NOT: "legacy ping unavailable"
// CHECK-PING: Dumping TypedVsLegacy::ping:
// CHECK-PING-NEXT: CXXMethodDecl {{.+}} ping 'void (int)'
// CHECK-PING-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-PING: UnavailableAttr {{.+}} <<invalid sloc>> "int ping unavailable"
// CHECK-PING-NOT: "zero-arg ping unavailable"
// CHECK-PING-NOT: "legacy ping unavailable"

// CHECK-SELF: Dumping TypedVsLegacy::selfOnly:
// CHECK-SELF-NEXT: CXXMethodDecl {{.+}} selfOnly 'void ()'
// CHECK-SELF: UnavailableAttr {{.+}} <<invalid sloc>> "legacy selfOnly unavailable"
// CHECK-SELF-NOT: "int selfOnly unavailable"
// CHECK-SELF: Dumping TypedVsLegacy::selfOnly:
// CHECK-SELF-NEXT: CXXMethodDecl {{.+}} selfOnly 'void (int)'
// CHECK-SELF-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-SELF: UnavailableAttr {{.+}} <<invalid sloc>> "int selfOnly unavailable"
// CHECK-SELF-NOT: "legacy selfOnly unavailable"
// CHECK-SELF: Dumping TypedVsLegacy::selfOnly:
// CHECK-SELF-NEXT: CXXMethodDecl {{.+}} selfOnly 'void (double)'
// CHECK-SELF-NEXT: ParmVarDecl {{.+}} 'double'
// CHECK-SELF: UnavailableAttr {{.+}} <<invalid sloc>> "legacy selfOnly unavailable"
// CHECK-SELF-NOT: "int selfOnly unavailable"

// CHECK-REWRITE: Dumping TypedVsLegacy::rewrite:
// CHECK-REWRITE-NEXT: CXXMethodDecl {{.+}} rewrite 'void (int *)'
// CHECK-REWRITE-NEXT: ParmVarDecl {{.+}} 'int *'
// CHECK-REWRITE: UnavailableAttr {{.+}} <<invalid sloc>> "legacy rewrite unavailable"

// CHECK-PARTIAL: Dumping TypedVsLegacy::partial:
// CHECK-PARTIAL-NEXT: CXXMethodDecl {{.+}} partial
// CHECK-PARTIAL-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-PARTIAL: ParmVarDecl {{.+}} 'int *{{.*}}':'int *'
// CHECK-PARTIAL: UnavailableAttr {{.+}} <<invalid sloc>> "legacy partial unavailable"
// CHECK-PARTIAL: Dumping TypedVsLegacy::partial:
// CHECK-PARTIAL-NEXT: CXXMethodDecl {{.+}} partial
// CHECK-PARTIAL-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-PARTIAL: ParmVarDecl {{.+}} 'double *{{.*}}':'double *'
// CHECK-PARTIAL: UnavailableAttr {{.+}} <<invalid sloc>> "legacy partial unavailable"

// CHECK-SINGLE: Dumping TypedVsLegacy::singleZeroTyped:
// CHECK-SINGLE-NEXT: CXXMethodDecl {{.+}} singleZeroTyped 'void ()'
// CHECK-SINGLE: UnavailableAttr {{.+}} <<invalid sloc>> "single zero-arg note still legacy"
// CHECK-SINGLE: Dumping TypedVsLegacy::singleZeroTyped:
// CHECK-SINGLE-NEXT: CXXMethodDecl {{.+}} singleZeroTyped 'void (int)'
// CHECK-SINGLE-NEXT: ParmVarDecl {{.+}} 'int'
// CHECK-SINGLE: UnavailableAttr {{.+}} <<invalid sloc>> "single zero-arg note still legacy"
