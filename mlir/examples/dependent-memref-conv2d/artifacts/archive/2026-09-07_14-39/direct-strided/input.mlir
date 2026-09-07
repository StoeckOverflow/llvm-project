func.func @dependent_conv2d_strided(
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
    %X : memref<f32>,
    %K : memref<f32>,
    %Y : memref<f32>)
    #types[
      %X : #memref<[%n, %cin, %oh, %ow, %kh, %kw], f32, offset: 0, strides: [%x_stride0, %x_stride1, %x_stride2, %unit_stride, %x_stride2, %unit_stride]>,
      %K : #memref<[%cout, %cin, %kh, %kw], f32, offset: 0, strides: [%k_stride0, %k_stride1, %k_stride2, %unit_stride]>,
      %Y : #memref<[%n, %cout, %oh, %ow], f32, offset: 0, strides: [%y_stride0, %y_stride1, %y_stride2, %unit_stride]>
    ] {
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
                %x = dependent_memref.load %X[%n_idx, %ci, %oh_idx, %ow_idx, %kh_idx, %kw_idx]
                    #memref<[%n, %cin, %oh, %ow, %kh, %kw], f32, offset: 0, strides: [%x_stride0, %x_stride1, %x_stride2, %unit_stride, %x_stride2, %unit_stride]>
                    : memref<f32> -> f32
                %k = dependent_memref.load %K[%co, %ci, %kh_idx, %kw_idx]
                    #memref<[%cout, %cin, %kh, %kw], f32, offset: 0, strides: [%k_stride0, %k_stride1, %k_stride2, %unit_stride]>
                    : memref<f32> -> f32
                %mul = arith.mulf %x, %k : f32
                %next = arith.addf %acc_kw, %mul : f32
                scf.yield %next : f32
              }
              scf.yield %sum_kw : f32
            }
            scf.yield %sum_kh : f32
          }
          dependent_memref.store %sum_ci, %Y[%n_idx, %co, %oh_idx, %ow_idx]
              #memref<[%n, %cout, %oh, %ow], f32, offset: 0, strides: [%y_stride0, %y_stride1, %y_stride2, %unit_stride]>
              : memref<f32>, f32
        }
      }
    }
  }
  return
}
