// RUN: mlir-opt %s -convert-dependent-tensor-to-dependent-memref -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @tensor_ops(%m: index, %n: index, %i: index, %j: index, %v: f32) -> tensor<?x?xf32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %old = dependent_tensor.extract %t[%i, %j] : f32
  %sum = arith.addf %old, %v : f32
  %r = dependent_tensor.insert %sum into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// CHECK-LABEL: "func.func"() <{{.*}}function_type = (index, index, index, index, f32) -> memref<?x?xf32>{{.*}}sym_name = "tensor_ops"
// CHECK: %[[ALLOC:.*]] = "dependent_memref.alloc"() <{result_refinement = []}> : () -> memref<?x?xf32>
// CHECK: %[[OLD:.*]] = "dependent_memref.load"(%[[ALLOC]], %{{.*}}, %{{.*}}) <{source_refinement = []}> : (memref<?x?xf32>, index, index) -> f32
// CHECK: %[[SUM:.*]] = "arith.addf"(%[[OLD]], %{{.*}}) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
// CHECK: "dependent_memref.store"(%[[SUM]], %[[ALLOC]], %{{.*}}, %{{.*}}) <{source_refinement = []}> : (f32, memref<?x?xf32>, index, index) -> ()
// CHECK: "func.return"(%[[ALLOC]]) : (memref<?x?xf32>) -> ()

// -----

func.func @tensor_dim(%m: index) -> index {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %d = dependent_tensor.dim %t, %c0, #dim %m : tensor<?xf32>
  return %d : index
}

// CHECK-LABEL: "func.func"() <{{.*}}function_type = (index) -> index{{.*}}sym_name = "tensor_dim"
// CHECK: "dependent_memref.alloc"() <{result_refinement = []}> : () -> memref<?xf32>
// CHECK: "func.return"(%{{.*}}) : (index) -> ()
