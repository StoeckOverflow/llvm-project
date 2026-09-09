func.func @memref_contraction_rank_16(
    %a0 : index,
    %a1 : index,
    %a2 : index,
    %a3 : index,
    %a4 : index,
    %a5 : index,
    %a6 : index,
    %a7 : index,
    %a8 : index,
    %a9 : index,
    %a10 : index,
    %a11 : index,
    %a12 : index,
    %a13 : index,
    %a14 : index,
    %a15 : index,
    %b0 : index,
    %b1 : index,
    %b2 : index,
    %b3 : index,
    %b4 : index,
    %b5 : index,
    %b6 : index,
    %b7 : index,
    %b8 : index,
    %b9 : index,
    %b10 : index,
    %b11 : index,
    %b12 : index,
    %b13 : index,
    %b14 : index,
    %b15 : index,
    %k0 : index,
    %k1 : index,
    %k2 : index,
    %k3 : index,
    %k4 : index,
    %k5 : index,
    %k6 : index,
    %k7 : index,
    %k8 : index,
    %k9 : index,
    %k10 : index,
    %k11 : index,
    %k12 : index,
    %k13 : index,
    %k14 : index,
    %k15 : index,
    %as0 : index,
    %as1 : index,
    %as2 : index,
    %as3 : index,
    %as4 : index,
    %as5 : index,
    %as6 : index,
    %as7 : index,
    %as8 : index,
    %as9 : index,
    %as10 : index,
    %as11 : index,
    %as12 : index,
    %as13 : index,
    %as14 : index,
    %as15 : index,
    %as16 : index,
    %as17 : index,
    %as18 : index,
    %as19 : index,
    %as20 : index,
    %as21 : index,
    %as22 : index,
    %as23 : index,
    %as24 : index,
    %as25 : index,
    %as26 : index,
    %as27 : index,
    %as28 : index,
    %as29 : index,
    %as30 : index,
    %as31 : index,
    %bs0 : index,
    %bs1 : index,
    %bs2 : index,
    %bs3 : index,
    %bs4 : index,
    %bs5 : index,
    %bs6 : index,
    %bs7 : index,
    %bs8 : index,
    %bs9 : index,
    %bs10 : index,
    %bs11 : index,
    %bs12 : index,
    %bs13 : index,
    %bs14 : index,
    %bs15 : index,
    %bs16 : index,
    %bs17 : index,
    %bs18 : index,
    %bs19 : index,
    %bs20 : index,
    %bs21 : index,
    %bs22 : index,
    %bs23 : index,
    %bs24 : index,
    %bs25 : index,
    %bs26 : index,
    %bs27 : index,
    %bs28 : index,
    %bs29 : index,
    %bs30 : index,
    %bs31 : index,
    %cs0 : index,
    %cs1 : index,
    %cs2 : index,
    %cs3 : index,
    %cs4 : index,
    %cs5 : index,
    %cs6 : index,
    %cs7 : index,
    %cs8 : index,
    %cs9 : index,
    %cs10 : index,
    %cs11 : index,
    %cs12 : index,
    %cs13 : index,
    %cs14 : index,
    %cs15 : index,
    %cs16 : index,
    %cs17 : index,
    %cs18 : index,
    %cs19 : index,
    %cs20 : index,
    %cs21 : index,
    %cs22 : index,
    %cs23 : index,
    %cs24 : index,
    %cs25 : index,
    %cs26 : index,
    %cs27 : index,
    %cs28 : index,
    %cs29 : index,
    %cs30 : index,
    %cs31 : index,
    %A : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>,
    %B : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>,
    %C : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>)
    #types[
      %A : #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15], f32, offset: 0, strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7, %as8, %as9, %as10, %as11, %as12, %as13, %as14, %as15, %as16, %as17, %as18, %as19, %as20, %as21, %as22, %as23, %as24, %as25, %as26, %as27, %as28, %as29, %as30, %as31]>,
      %B : #memref<[%k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7, %bs8, %bs9, %bs10, %bs11, %bs12, %bs13, %bs14, %bs15, %bs16, %bs17, %bs18, %bs19, %bs20, %bs21, %bs22, %bs23, %bs24, %bs25, %bs26, %bs27, %bs28, %bs29, %bs30, %bs31]>,
      %C : #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7, %cs8, %cs9, %cs10, %cs11, %cs12, %cs13, %cs14, %cs15, %cs16, %cs17, %cs18, %cs19, %cs20, %cs21, %cs22, %cs23, %cs24, %cs25, %cs26, %cs27, %cs28, %cs29, %cs30, %cs31]>
    ] {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %ia0 = %c0 to %a0 step %c1 {
    scf.for %ia1 = %c0 to %a1 step %c1 {
      scf.for %ia2 = %c0 to %a2 step %c1 {
        scf.for %ia3 = %c0 to %a3 step %c1 {
          scf.for %ia4 = %c0 to %a4 step %c1 {
            scf.for %ia5 = %c0 to %a5 step %c1 {
              scf.for %ia6 = %c0 to %a6 step %c1 {
                scf.for %ia7 = %c0 to %a7 step %c1 {
                  scf.for %ia8 = %c0 to %a8 step %c1 {
                    scf.for %ia9 = %c0 to %a9 step %c1 {
                      scf.for %ia10 = %c0 to %a10 step %c1 {
                        scf.for %ia11 = %c0 to %a11 step %c1 {
                          scf.for %ia12 = %c0 to %a12 step %c1 {
                            scf.for %ia13 = %c0 to %a13 step %c1 {
                              scf.for %ia14 = %c0 to %a14 step %c1 {
                                scf.for %ia15 = %c0 to %a15 step %c1 {
                                  scf.for %ib0 = %c0 to %b0 step %c1 {
                                    scf.for %ib1 = %c0 to %b1 step %c1 {
                                      scf.for %ib2 = %c0 to %b2 step %c1 {
                                        scf.for %ib3 = %c0 to %b3 step %c1 {
                                          scf.for %ib4 = %c0 to %b4 step %c1 {
                                            scf.for %ib5 = %c0 to %b5 step %c1 {
                                              scf.for %ib6 = %c0 to %b6 step %c1 {
                                                scf.for %ib7 = %c0 to %b7 step %c1 {
                                                  scf.for %ib8 = %c0 to %b8 step %c1 {
                                                    scf.for %ib9 = %c0 to %b9 step %c1 {
                                                      scf.for %ib10 = %c0 to %b10 step %c1 {
                                                        scf.for %ib11 = %c0 to %b11 step %c1 {
                                                          scf.for %ib12 = %c0 to %b12 step %c1 {
                                                            scf.for %ib13 = %c0 to %b13 step %c1 {
                                                              scf.for %ib14 = %c0 to %b14 step %c1 {
                                                                scf.for %ib15 = %c0 to %b15 step %c1 {
                                                                  %sum0 = scf.for %ik0 = %c0 to %k0 step %c1 iter_args(%acc0 = %zero) -> (f32) {
                                                                    %sum1 = scf.for %ik1 = %c0 to %k1 step %c1 iter_args(%acc1 = %acc0) -> (f32) {
                                                                      %sum2 = scf.for %ik2 = %c0 to %k2 step %c1 iter_args(%acc2 = %acc1) -> (f32) {
                                                                        %sum3 = scf.for %ik3 = %c0 to %k3 step %c1 iter_args(%acc3 = %acc2) -> (f32) {
                                                                          %sum4 = scf.for %ik4 = %c0 to %k4 step %c1 iter_args(%acc4 = %acc3) -> (f32) {
                                                                            %sum5 = scf.for %ik5 = %c0 to %k5 step %c1 iter_args(%acc5 = %acc4) -> (f32) {
                                                                              %sum6 = scf.for %ik6 = %c0 to %k6 step %c1 iter_args(%acc6 = %acc5) -> (f32) {
                                                                                %sum7 = scf.for %ik7 = %c0 to %k7 step %c1 iter_args(%acc7 = %acc6) -> (f32) {
                                                                                  %sum8 = scf.for %ik8 = %c0 to %k8 step %c1 iter_args(%acc8 = %acc7) -> (f32) {
                                                                                    %sum9 = scf.for %ik9 = %c0 to %k9 step %c1 iter_args(%acc9 = %acc8) -> (f32) {
                                                                                      %sum10 = scf.for %ik10 = %c0 to %k10 step %c1 iter_args(%acc10 = %acc9) -> (f32) {
                                                                                        %sum11 = scf.for %ik11 = %c0 to %k11 step %c1 iter_args(%acc11 = %acc10) -> (f32) {
                                                                                          %sum12 = scf.for %ik12 = %c0 to %k12 step %c1 iter_args(%acc12 = %acc11) -> (f32) {
                                                                                            %sum13 = scf.for %ik13 = %c0 to %k13 step %c1 iter_args(%acc13 = %acc12) -> (f32) {
                                                                                              %sum14 = scf.for %ik14 = %c0 to %k14 step %c1 iter_args(%acc14 = %acc13) -> (f32) {
                                                                                                %sum15 = scf.for %ik15 = %c0 to %k15 step %c1 iter_args(%acc15 = %acc14) -> (f32) {
                                                                                                  %lhs = dependent_memref.load %A[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15] #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15], f32, offset: 0, strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7, %as8, %as9, %as10, %as11, %as12, %as13, %as14, %as15, %as16, %as17, %as18, %as19, %as20, %as21, %as22, %as23, %as24, %as25, %as26, %as27, %as28, %as29, %as30, %as31]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
                                                                                                  %rhs = dependent_memref.load %B[%ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15] #memref<[%k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7, %bs8, %bs9, %bs10, %bs11, %bs12, %bs13, %bs14, %bs15, %bs16, %bs17, %bs18, %bs19, %bs20, %bs21, %bs22, %bs23, %bs24, %bs25, %bs26, %bs27, %bs28, %bs29, %bs30, %bs31]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
                                                                                                  %mul = arith.mulf %lhs, %rhs : f32
                                                                                                  %next = arith.addf %acc15, %mul : f32
                                                                                                  scf.yield %next : f32
                                                                                                }
                                                                                                scf.yield %sum15 : f32
                                                                                              }
                                                                                              scf.yield %sum14 : f32
                                                                                            }
                                                                                            scf.yield %sum13 : f32
                                                                                          }
                                                                                          scf.yield %sum12 : f32
                                                                                        }
                                                                                        scf.yield %sum11 : f32
                                                                                      }
                                                                                      scf.yield %sum10 : f32
                                                                                    }
                                                                                    scf.yield %sum9 : f32
                                                                                  }
                                                                                  scf.yield %sum8 : f32
                                                                                }
                                                                                scf.yield %sum7 : f32
                                                                              }
                                                                              scf.yield %sum6 : f32
                                                                            }
                                                                            scf.yield %sum5 : f32
                                                                          }
                                                                          scf.yield %sum4 : f32
                                                                        }
                                                                        scf.yield %sum3 : f32
                                                                      }
                                                                      scf.yield %sum2 : f32
                                                                    }
                                                                    scf.yield %sum1 : f32
                                                                  }
                                                                  dependent_memref.store %sum0, %C[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15] #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7, %cs8, %cs9, %cs10, %cs11, %cs12, %cs13, %cs14, %cs15, %cs16, %cs17, %cs18, %cs19, %cs20, %cs21, %cs22, %cs23, %cs24, %cs25, %cs26, %cs27, %cs28, %cs29, %cs30, %cs31]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
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
