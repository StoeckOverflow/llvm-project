// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @non_dominating_anchor(%cond : i1) {
  cf.cond_br %cond, ^bb1, ^bb2
^bb1:
  %d = "builtin.unrealized_conversion_cast"() : () -> index
  cf.br ^bb2
^bb2:
  // expected-error@+1 {{dependent tensor anchor does not dominate dependent type use}}
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}

// -----

func.func @illegal_cross_region_anchor(%x : index) {
  test.isolated_region %x {
    // expected-error@+1 {{dependent tensor anchor crosses an isolated-from-above boundary}}
    %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x], f32>
  }
  return
}

// -----

func.func @mixed_anchor_non_dominating(%x : index, %cond : i1) {
  cf.cond_br %cond, ^bb1, ^bb2
^bb1:
  %d = "builtin.unrealized_conversion_cast"() : () -> index
  cf.br ^bb2
^bb2:
  // expected-error@+1 {{dependent tensor anchor does not dominate dependent type use}}
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x, %d], f32>
  return
}
