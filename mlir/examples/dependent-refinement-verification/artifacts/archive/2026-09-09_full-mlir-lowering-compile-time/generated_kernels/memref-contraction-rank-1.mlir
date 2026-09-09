func.func @memref_contraction_rank_1(
    %a0 : index,
    %b0 : index,
    %k0 : index,
    %as0 : index,
    %as1 : index,
    %bs0 : index,
    %bs1 : index,
    %cs0 : index,
    %cs1 : index,
    %A : memref<?x?xf32>,
    %B : memref<?x?xf32>,
    %C : memref<?x?xf32>)
    #types[
      %A : #memref<[%a0, %k0], f32, offset: 0, strides: [%as0, %as1]>,
      %B : #memref<[%k0, %b0], f32, offset: 0, strides: [%bs0, %bs1]>,
      %C : #memref<[%a0, %b0], f32, offset: 0, strides: [%cs0, %cs1]>
    ] {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ib0 = %c0 to %b0 step %c1 {
      %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
        %lhs = dependent_memref.load %A[%ia0, %ik0] #memref<[%a0, %k0], f32, offset: 0, strides: [%as0, %as1]> : memref<?x?xf32>
        %rhs = dependent_memref.load %B[%ik0, %ib0] #memref<[%k0, %b0], f32, offset: 0, strides: [%bs0, %bs1]> : memref<?x?xf32>
        %mul = arith.mulf %lhs, %rhs : f32
        %next = arith.addf %acc0, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum0, %C[%ia0, %ib0] #memref<[%a0, %b0], f32, offset: 0, strides: [%cs0, %cs1]> : memref<?x?xf32>
    }
  }
  return
}
