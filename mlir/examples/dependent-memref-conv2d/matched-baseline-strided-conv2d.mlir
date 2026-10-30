// Matched-stride baseline used in the rebuttal comparison.
// Accepts the same explicit strides as dependent-strided-conv2d.mlir.
func.func @matched_baseline_conv2d(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %x_stride0 : index,
    %x_stride1 : index,
    %x_stride2 : index,
    %unit_stride : index,
    %k_stride0 : index,
    %k_stride1 : index,
    %k_stride2 : index,
    %y_stride0 : index,
    %y_stride1 : index,
    %y_stride2 : index,
    %Xflat : memref<f32>,
    %Kflat : memref<f32>,
    %Yflat : memref<f32>)
 {
  %X = memref.reinterpret_cast %Xflat to offset: [0], sizes: [%n, %cin, %oh, %ow, %kh, %kw], strides: [%x_stride0, %x_stride1, %x_stride2, %unit_stride, %x_stride2, %unit_stride] : memref<f32> to memref<?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?], offset: 0>>
  %K = memref.reinterpret_cast %Kflat to offset: [0], sizes: [%cout, %cin, %kh, %kw], strides: [%k_stride0, %k_stride1, %k_stride2, %unit_stride] : memref<f32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: 0>>
  %Y = memref.reinterpret_cast %Yflat to offset: [0], sizes: [%n, %cout, %oh, %ow], strides: [%y_stride0, %y_stride1, %y_stride2, %unit_stride] : memref<f32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: 0>>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32

  scf.for %n_idx = %c0 to %n step %c1 {
    scf.for %co = %c0 to %cout step %c1 {
      scf.for %oh_idx = %c0 to %oh step %c1 {
        scf.for %ow_idx = %c0 to %ow step %c1 {
          %sum_ci = scf.for %ci = %c0 to %cin step %c1 iter_args(%acc_ci = %zero) -> (f32) {
            %sum_kh = scf.for %kh_idx = %c0 to %kh step %c1 iter_args(%acc_kh = %acc_ci) -> (f32) {
              %sum_kw = scf.for %kw_idx = %c0 to %kw step %c1 iter_args(%acc_kw = %acc_kh) -> (f32) {
                %x = memref.load %X[%n_idx, %ci, %oh_idx, %ow_idx, %kh_idx, %kw_idx]
                    : memref<?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?], offset: 0>>
                %k = memref.load %K[%co, %ci, %kh_idx, %kw_idx]
                    : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: 0>>
                %mul = arith.mulf %x, %k : f32
                %next = arith.addf %acc_kw, %mul : f32
                scf.yield %next : f32
              }
              scf.yield %sum_kw : f32
            }
            scf.yield %sum_kh : f32
          }
          memref.store %sum_ci, %Y[%n_idx, %co, %oh_idx, %ow_idx]
              : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: 0>>
        }
      }
    }
  }
  return
}
