func.func @baseline_matmul_strided(
    %n : index, %m : index, %k : index,
    %as0 : index, %as1 : index,
    %bs0 : index, %bs1 : index,
    %cs0 : index, %cs1 : index,
    %Aflat : memref<f32>,
    %Bflat : memref<f32>,
    %Cflat : memref<f32>) {
  %A = memref.reinterpret_cast %Aflat to
      offset: [0], sizes: [%n, %k], strides: [%as0, %as1]
      : memref<f32> to memref<?x?xf32, strided<[?, ?], offset: 0>>
  %B = memref.reinterpret_cast %Bflat to
      offset: [0], sizes: [%k, %m], strides: [%bs0, %bs1]
      : memref<f32> to memref<?x?xf32, strided<[?, ?], offset: 0>>
  %C = memref.reinterpret_cast %Cflat to
      offset: [0], sizes: [%n, %m], strides: [%cs0, %cs1]
      : memref<f32> to memref<?x?xf32, strided<[?, ?], offset: 0>>
  %zero = arith.constant 0.0 : f32
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %p = %c0 to %k step %c1
          iter_args(%acc = %zero) -> (f32) {
        %a = memref.load %A[%i, %p]
            : memref<?x?xf32, strided<[?, ?], offset: 0>>
        %b = memref.load %B[%p, %j]
            : memref<?x?xf32, strided<[?, ?], offset: 0>>
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      memref.store %sum, %C[%i, %j]
          : memref<?x?xf32, strided<[?, ?], offset: 0>>
    }
  }
  return
}
