func.func @baseline_conv2d_strided(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %Xflat : memref<?xf32>,
    %Kflat : memref<?xf32>,
    %Yflat : memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %hw = arith.muli %h, %w : index
  %chw = arith.muli %cin, %hw : index
  %khkw = arith.muli %kh, %kw : index
  %cin_khkw = arith.muli %cin, %khkw : index
  %ohow = arith.muli %oh, %ow : index
  %cout_ohow = arith.muli %cout, %ohow : index

  %X = memref.reinterpret_cast %Xflat to
      offset: [%c0], sizes: [%n, %cin, %oh, %ow, %kh, %kw],
      strides: [%chw, %hw, %w, %c1, %w, %c1]
      : memref<?xf32> to memref<?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?], offset: ?>>
  %K = memref.reinterpret_cast %Kflat to
      offset: [%c0], sizes: [%cout, %cin, %kh, %kw],
      strides: [%cin_khkw, %khkw, %kw, %c1]
      : memref<?xf32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
  %Y = memref.reinterpret_cast %Yflat to
      offset: [%c0], sizes: [%n, %cout, %oh, %ow],
      strides: [%cout_ohow, %ohow, %ow, %c1]
      : memref<?xf32> to memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>

  scf.for %n_idx = %c0 to %n step %c1 {
    scf.for %co = %c0 to %cout step %c1 {
      scf.for %oh_idx = %c0 to %oh step %c1 {
        scf.for %ow_idx = %c0 to %ow step %c1 {
          %sum_ci = scf.for %ci = %c0 to %cin step %c1 iter_args(%acc_ci = %zero) -> (f32) {
            %sum_kh = scf.for %kh_idx = %c0 to %kh step %c1 iter_args(%acc_kh = %acc_ci) -> (f32) {
              %sum_kw = scf.for %kw_idx = %c0 to %kw step %c1 iter_args(%acc_kw = %acc_kh) -> (f32) {
                %x = memref.load %X[%n_idx, %ci, %oh_idx, %ow_idx, %kh_idx, %kw_idx]
                    : memref<?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?], offset: ?>>
                %k = memref.load %K[%co, %ci, %kh_idx, %kw_idx]
                    : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
                %mul = arith.mulf %x, %k : f32
                %next = arith.addf %acc_kw, %mul : f32
                scf.yield %next : f32
              }
              scf.yield %sum_kw : f32
            }
            scf.yield %sum_kh : f32
          }
          memref.store %sum_ci, %Y[%n_idx, %co, %oh_idx, %ow_idx]
              : memref<?x?x?x?xf32, strided<[?, ?, ?, ?], offset: ?>>
        }
      }
    }
  }
  return
}
