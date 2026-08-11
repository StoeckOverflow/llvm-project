func.func @baseline_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>) {
    %C_row = scf.for %j = %c0 to %m step %c1 iter_args(%Cj = %Ci)
        -> (tensor<?x?xf32>) {
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%sum_iter = %zero)
          -> (f32) {
        %a = tensor.extract %A[%i, %kk] : tensor<?x?xf32>
        %b = tensor.extract %B[%kk, %j] : tensor<?x?xf32>
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %sum_iter, %mul : f32
        scf.yield %next : f32
      }
      %updated = tensor.insert %sum into %Cj[%i, %j] : tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %C_row : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}
