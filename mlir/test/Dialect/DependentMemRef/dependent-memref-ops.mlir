// RUN: mlir-opt %s -split-input-file -verify-diagnostics -mlir-print-op-generic | FileCheck %s

func.func @basic(%n : index, %m : index, %s0 : index, %s1 : index, %i : index, %j : index, %v : f32) {
  %0 = dependent_memref.alloc #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  %d0 = dependent_memref.dim %0, %i, #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  %d1 = dependent_memref.dim_exact %0 axis(1 : i32) #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  %old = dependent_memref.load %0[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32> -> f32
  dependent_memref.store %v, %0[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>, f32
  %1 = dependent_memref.cast %0, #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32> to memref<?x?xf32>
  %2 = dependent_memref.reinterpret_cast %1, #memref<[%n, %m], f32> : memref<?x?xf32> to memref<?x?xf32>
  dependent_memref.dealloc %2 : memref<?x?xf32>
  return
}

// CHECK-LABEL: "func.func"() <{{.*}}sym_name = "basic"
// CHECK: "dependent_memref.alloc"() <{result_refinement = []}> : () -> memref<?x?xf32>
// CHECK: "dependent_memref.dim"(%{{.*}}, %{{.*}}) <{source_refinement = []}> : (memref<?x?xf32>, index) -> index
// CHECK: "dependent_memref.dim_exact"(%{{.*}}) <{axis = 1 : i32, source_refinement = []}> : (memref<?x?xf32>) -> index
// CHECK: "dependent_memref.load"(%{{.*}}, %{{.*}}, %{{.*}}) <{source_refinement = []}> : (memref<?x?xf32>, index, index) -> f32
// CHECK: "dependent_memref.store"(%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}) <{source_refinement = []}> : (f32, memref<?x?xf32>, index, index) -> ()
// CHECK: "dependent_memref.cast"(%{{.*}}) <{result_refinement = []}> : (memref<?x?xf32>) -> memref<?x?xf32>
// CHECK: "dependent_memref.reinterpret_cast"(%{{.*}}) <{result_refinement = []}> : (memref<?x?xf32>) -> memref<?x?xf32>
// CHECK: "dependent_memref.dealloc"(%{{.*}}) : (memref<?x?xf32>) -> ()

// -----

func.func @rank_mismatch(%n : index) {
  // expected-error@below {{dependent memref rank mismatch}}
  %0 = dependent_memref.alloc #memref<[%n], f32> : memref<?x?xf32>
  return
}

// -----

func.func @static_dim(%n : index) {
  // expected-error@below {{requires dependent dimensions to correspond to dynamic memref dims}}
  %0 = dependent_memref.alloc #memref<[%n], f32> : memref<4xf32>
  return
}

// -----

func.func @stride_mismatch(%n : index, %m : index, %s0 : index) {
  // expected-error@below {{dependent memref stride count must match rank}}
  %0 = dependent_memref.alloc #memref<[%n, %m], f32, offset: 0, strides: [%s0]> : memref<?x?xf32>
  return
}
