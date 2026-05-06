// RUN: mlir-opt %s -verify-diagnostics

func.func @conv_result_channel_property_mismatch(
    %n : index, %oh : index, %ow : index, %f : index, %bad_f : index,
    %ni : index, %ohi : index, %owi : index, %fi : index) {
  %out = dependent_tensor.make %n, %oh, %ow, %f dims[n, oh, ow, f] : tensor<?x?x?x?xf32>
  %sum = dependent_tensor.extract %out[%ni, %ohi, %owi, %fi] : tensor<?x?x?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %bad = dependent_tensor.insert %sum into %out[%ni, %ohi, %owi, %fi] result_dims[%n, %oh, %ow, %bad_f] dims[n, oh, ow, f] : f32 into tensor<?x?x?x?xf32>
  return
}

// -----

func.func @conv_rank_property_missing_value(
    %n : index, %oh : index, %ow : index, %f : index,
    %ni : index, %ohi : index, %owi : index, %fi : index) {
  %out = dependent_tensor.make %n, %oh, %ow, %f dims[n, oh, ow, f] : tensor<?x?x?x?xf32>
  %sum = dependent_tensor.extract %out[%ni, %ohi, %owi, %fi] : tensor<?x?x?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op requires one dependent dimension value per result dimension}}
  %bad = dependent_tensor.insert %sum into %out[%ni, %ohi, %owi, %fi] result_dims[%n, %oh, %ow] dims[n, oh, ow] : f32 into tensor<?x?x?x?xf32>
  return
}
