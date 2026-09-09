func.func @baseline_memref_contraction_rank_2(
    %a0 : index,
    %a1 : index,
    %b0 : index,
    %b1 : index,
    %k0 : index,
    %k1 : index,
    %as0 : index,
    %as1 : index,
    %as2 : index,
    %as3 : index,
    %bs0 : index,
    %bs1 : index,
    %bs2 : index,
    %bs3 : index,
    %cs0 : index,
    %cs1 : index,
    %cs2 : index,
    %cs3 : index,
    %A_flat : memref<?xf32>,
    %B_flat : memref<?xf32>,
    %C_flat : memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %A = memref.reinterpret_cast %A_flat to offset: [0], sizes: [%a0, %a1, %k0, %k1], strides: [%as0, %as1, %as2, %as3] : memref<?xf32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
  %B = memref.reinterpret_cast %B_flat to offset: [0], sizes: [%k0, %k1, %b0, %b1], strides: [%bs0, %bs1, %bs2, %bs3] : memref<?xf32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
  %C = memref.reinterpret_cast %C_flat to offset: [0], sizes: [%a0, %a1, %b0, %b1], strides: [%cs0, %cs1, %cs2, %cs3] : memref<?xf32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ia1 = %c0 to %a1 step %c1 {
      scf.for %ib0 = %c0 to %b0 step %c1 {
        scf.for %ib1 = %c0 to %b1 step %c1 {
          %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
            %sum1 = scf.for %ik1 = %c0 to %k1 step %c1 iter_args(%acc1 = %acc0) -> (f32) {
              %lhs = memref.load %A[%ia0, %ia1, %ik0, %ik1] : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
              %rhs = memref.load %B[%ik0, %ik1, %ib0, %ib1] : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
              %mul = arith.mulf %lhs, %rhs : f32
              %next = arith.addf %acc1, %mul : f32
              scf.yield %next : f32
            }
            scf.yield %sum1 : f32
          }
          memref.store %sum0, %C[%ia0, %ia1, %ib0, %ib1] : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
        }
      }
    }
  }
  return
}
