func.func @baseline_memref_contraction_rank_4(
    %a0 : index,
    %a1 : index,
    %a2 : index,
    %a3 : index,
    %b0 : index,
    %b1 : index,
    %b2 : index,
    %b3 : index,
    %k0 : index,
    %k1 : index,
    %k2 : index,
    %k3 : index,
    %as0 : index,
    %as1 : index,
    %as2 : index,
    %as3 : index,
    %as4 : index,
    %as5 : index,
    %as6 : index,
    %as7 : index,
    %bs0 : index,
    %bs1 : index,
    %bs2 : index,
    %bs3 : index,
    %bs4 : index,
    %bs5 : index,
    %bs6 : index,
    %bs7 : index,
    %cs0 : index,
    %cs1 : index,
    %cs2 : index,
    %cs3 : index,
    %cs4 : index,
    %cs5 : index,
    %cs6 : index,
    %cs7 : index,
    %A_flat : memref<?xf32>,
    %B_flat : memref<?xf32>,
    %C_flat : memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %A = memref.reinterpret_cast %A_flat to offset: [0], sizes: [%a0, %a1, %a2, %a3, %k0, %k1, %k2, %k3], strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7] : memref<?xf32> to memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
  %B = memref.reinterpret_cast %B_flat to offset: [0], sizes: [%k0, %k1, %k2, %k3, %b0, %b1, %b2, %b3], strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7] : memref<?xf32> to memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
  %C = memref.reinterpret_cast %C_flat to offset: [0], sizes: [%a0, %a1, %a2, %a3, %b0, %b1, %b2, %b3], strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7] : memref<?xf32> to memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ia1 = %c0 to %a1 step %c1 {
      scf.for %ia2 = %c0 to %a2 step %c1 {
        scf.for %ia3 = %c0 to %a3 step %c1 {
          scf.for %ib0 = %c0 to %b0 step %c1 {
            scf.for %ib1 = %c0 to %b1 step %c1 {
              scf.for %ib2 = %c0 to %b2 step %c1 {
                scf.for %ib3 = %c0 to %b3 step %c1 {
                  %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
                    %sum1 = scf.for %ik1 = %c0 to %k1 step %c1 iter_args(%acc1 = %acc0) -> (f32) {
                      %sum2 = scf.for %ik2 = %c0 to %k2 step %c1 iter_args(%acc2 = %acc1) -> (f32) {
                        %sum3 = scf.for %ik3 = %c0 to %k3 step %c1 iter_args(%acc3 = %acc2) -> (f32) {
                          %lhs = memref.load %A[%ia0, %ia1, %ia2, %ia3, %ik0, %ik1, %ik2, %ik3] : memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
                          %rhs = memref.load %B[%ik0, %ik1, %ik2, %ik3, %ib0, %ib1, %ib2, %ib3] : memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
                          %mul = arith.mulf %lhs, %rhs : f32
                          %next = arith.addf %acc3, %mul : f32
                          scf.yield %next : f32
                        }
                        scf.yield %sum3 : f32
                      }
                      scf.yield %sum2 : f32
                    }
                    scf.yield %sum1 : f32
                  }
                  memref.store %sum0, %C[%ia0, %ia1, %ia2, %ia3, %ib0, %ib1, %ib2, %ib3] : memref<?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
                }
              }
            }
          }
        }
      }
    }
  }
  return
}
