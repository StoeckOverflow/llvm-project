func.func @baseline_conv2d_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
 {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32

  %Y_final = scf.for %n_idx = %c0 to %n step %c1 iter_args(%Yn = %Y)
      -> (tensor<?x?x?x?xf32>) {
    %Y_co = scf.for %co = %c0 to %cout step %c1 iter_args(%Yco = %Yn)
        -> (tensor<?x?x?x?xf32>) {
      %Y_oh = scf.for %oh_idx = %c0 to %oh step %c1 iter_args(%Yoh = %Yco)
          -> (tensor<?x?x?x?xf32>) {
        %Y_ow = scf.for %ow_idx = %c0 to %ow step %c1 iter_args(%Yow = %Yoh)
            -> (tensor<?x?x?x?xf32>) {
          %sum_ci = scf.for %ci = %c0 to %cin step %c1 iter_args(%acc_ci = %zero) -> (f32) {
            %sum_kh = scf.for %kh_idx = %c0 to %kh step %c1 iter_args(%acc_kh = %acc_ci) -> (f32) {
              %sum_kw = scf.for %kw_idx = %c0 to %kw step %c1 iter_args(%acc_kw = %acc_kh) -> (f32) {
                %x = tensor.extract %X[%n_idx, %ci, %oh_idx, %ow_idx, %kh_idx, %kw_idx] : tensor<?x?x?x?x?x?xf32>
                %k = tensor.extract %K[%co, %ci, %kh_idx, %kw_idx] : tensor<?x?x?x?xf32>
                %mul = arith.mulf %x, %k : f32
                %next = arith.addf %acc_kw, %mul : f32
                scf.yield %next : f32
              }
              scf.yield %sum_kw : f32
            }
            scf.yield %sum_kh : f32
          }
          %updated = tensor.insert %sum_ci into %Yow[%n_idx, %co, %oh_idx, %ow_idx] : tensor<?x?x?x?xf32>
          scf.yield %updated : tensor<?x?x?x?xf32>
        }
        scf.yield %Y_ow : tensor<?x?x?x?xf32>
      }
      scf.yield %Y_oh : tensor<?x?x?x?xf32>
    }
    scf.yield %Y_co : tensor<?x?x?x?xf32>
  }
  return %Y_final : tensor<?x?x?x?xf32>
}
