func.func @dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %C : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
    %C_row = scf.for %j = %c0 to %m step %c1 iter_args(%Cj = %Ci)
        -> (tensor<?x?xf32>)
        #types[%Cj : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%sum_iter = %zero)
          -> (f32) {
        %a = dependent_tensor.extract %A[%i, %kk] : f32
        %b = dependent_tensor.extract %B[%kk, %j] : f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %sum_iter, %mul : f32
        scf.yield %next : f32
      }
      %updated = dependent_tensor.insert %sum into %Cj[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %C_row : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}
