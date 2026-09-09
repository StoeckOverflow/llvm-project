func.func @memref_contraction_rank_2(
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
    %A : memref<?x?x?x?xf32>,
    %B : memref<?x?x?x?xf32>,
    %C : memref<?x?x?x?xf32>)
    #types[
      %A : #memref<[%a0, %a1, %k0, %k1], f32, offset: 0, strides: [%as0, %as1, %as2, %as3]>,
      %B : #memref<[%k0, %k1, %b0, %b1], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3]>,
      %C : #memref<[%a0, %a1, %b0, %b1], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3]>
    ] {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ia1 = %c0 to %a1 step %c1 {
      scf.for %ib0 = %c0 to %b0 step %c1 {
        scf.for %ib1 = %c0 to %b1 step %c1 {
          %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
            %sum1 = scf.for %ik1 = %c0 to %k1 step %c1 iter_args(%acc1 = %acc0) -> (f32) {
              %lhs = dependent_memref.load %A[%ia0, %ia1, %ik0, %ik1] #memref<[%a0, %a1, %k0, %k1], f32, offset: 0, strides: [%as0, %as1, %as2, %as3]> : memref<?x?x?x?xf32>
              %rhs = dependent_memref.load %B[%ik0, %ik1, %ib0, %ib1] #memref<[%k0, %k1, %b0, %b1], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3]> : memref<?x?x?x?xf32>
              %mul = arith.mulf %lhs, %rhs : f32
              %next = arith.addf %acc1, %mul : f32
              scf.yield %next : f32
            }
            scf.yield %sum1 : f32
          }
          dependent_memref.store %sum0, %C[%ia0, %ia1, %ib0, %ib1] #memref<[%a0, %a1, %b0, %b1], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3]> : memref<?x?x?x?xf32>
        }
      }
    }
  }
  return
}
