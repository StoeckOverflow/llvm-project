func.func @baseline_memref_contraction_rank_1(
    %a0 : index,
    %b0 : index,
    %k0 : index,
    %as0 : index,
    %as1 : index,
    %bs0 : index,
    %bs1 : index,
    %cs0 : index,
    %cs1 : index,
    %A_flat : memref<?xf32>,
    %B_flat : memref<?xf32>,
    %C_flat : memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %A = memref.reinterpret_cast %A_flat to offset: [0], sizes: [%a0, %k0], strides: [%as0, %as1] : memref<?xf32> to memref<?x?xf32, strided<[?, ?], offset: ?>>
  %B = memref.reinterpret_cast %B_flat to offset: [0], sizes: [%k0, %b0], strides: [%bs0, %bs1] : memref<?xf32> to memref<?x?xf32, strided<[?, ?], offset: ?>>
  %C = memref.reinterpret_cast %C_flat to offset: [0], sizes: [%a0, %b0], strides: [%cs0, %cs1] : memref<?xf32> to memref<?x?xf32, strided<[?, ?], offset: ?>>
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ib0 = %c0 to %b0 step %c1 {
      %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
        %lhs = memref.load %A[%ia0, %ik0] : memref<?x?xf32, strided<[?, ?], offset: ?>>
        %rhs = memref.load %B[%ik0, %ib0] : memref<?x?xf32, strided<[?, ?], offset: ?>>
        %mul = arith.mulf %lhs, %rhs : f32
        %next = arith.addf %acc0, %mul : f32
        scf.yield %next : f32
      }
      memref.store %sum0, %C[%ia0, %ib0] : memref<?x?xf32, strided<[?, ?], offset: ?>>
    }
  }
  return
}
