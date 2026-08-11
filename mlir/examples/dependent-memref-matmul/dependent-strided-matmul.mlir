func.func @dependent_matmul_strided(%n : index, %m : index, %k : index,
                                    %as0 : index, %as1 : index,
                                    %bs0 : index, %bs1 : index,
                                    %cs0 : index, %cs1 : index,
                                    %Aflat : memref<f32>,
                                    %Bflat : memref<f32>,
                                    %Cflat : memref<f32>) {
  %A = dependent_memref.reinterpret_cast %Aflat, #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<f32> to memref<?x?xf32>
  %B = dependent_memref.reinterpret_cast %Bflat, #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<f32> to memref<?x?xf32>
  %C = dependent_memref.reinterpret_cast %Cflat, #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<f32> to memref<?x?xf32>
  func.call @dependent_matmul_strided_typed(%n, %m, %k, %as0, %as1, %bs0, %bs1, %cs0, %cs1, %A, %B, %C) : (index, index, index, index, index, index, index, index, index, memref<?x?xf32>, memref<?x?xf32>, memref<?x?xf32>) -> ()
  return
}

func.func @dependent_matmul_strided_typed(%n : index, %m : index, %k : index,
                                          %as0 : index, %as1 : index,
                                          %bs0 : index, %bs1 : index,
                                          %cs0 : index, %cs1 : index,
                                          %A : memref<?x?xf32>,
                                          %B : memref<?x?xf32>,
                                          %C : memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %zero) -> (f32) {
        %a = dependent_memref.load %A[%i, %p] #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<?x?xf32> -> f32
        %b = dependent_memref.load %B[%p, %j] #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<?x?xf32> -> f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum, %C[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<?x?xf32>, f32
    }
  }
  return
}
