func.func @memref_contraction_rank_32(
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
    %a16 : index,
    %a17 : index,
    %a18 : index,
    %a19 : index,
    %a20 : index,
    %a21 : index,
    %a22 : index,
    %a23 : index,
    %a24 : index,
    %a25 : index,
    %a26 : index,
    %a27 : index,
    %a28 : index,
    %a29 : index,
    %a30 : index,
    %a31 : index,
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
    %b16 : index,
    %b17 : index,
    %b18 : index,
    %b19 : index,
    %b20 : index,
    %b21 : index,
    %b22 : index,
    %b23 : index,
    %b24 : index,
    %b25 : index,
    %b26 : index,
    %b27 : index,
    %b28 : index,
    %b29 : index,
    %b30 : index,
    %b31 : index,
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
    %k16 : index,
    %k17 : index,
    %k18 : index,
    %k19 : index,
    %k20 : index,
    %k21 : index,
    %k22 : index,
    %k23 : index,
    %k24 : index,
    %k25 : index,
    %k26 : index,
    %k27 : index,
    %k28 : index,
    %k29 : index,
    %k30 : index,
    %k31 : index,
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
    %as32 : index,
    %as33 : index,
    %as34 : index,
    %as35 : index,
    %as36 : index,
    %as37 : index,
    %as38 : index,
    %as39 : index,
    %as40 : index,
    %as41 : index,
    %as42 : index,
    %as43 : index,
    %as44 : index,
    %as45 : index,
    %as46 : index,
    %as47 : index,
    %as48 : index,
    %as49 : index,
    %as50 : index,
    %as51 : index,
    %as52 : index,
    %as53 : index,
    %as54 : index,
    %as55 : index,
    %as56 : index,
    %as57 : index,
    %as58 : index,
    %as59 : index,
    %as60 : index,
    %as61 : index,
    %as62 : index,
    %as63 : index,
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
    %bs32 : index,
    %bs33 : index,
    %bs34 : index,
    %bs35 : index,
    %bs36 : index,
    %bs37 : index,
    %bs38 : index,
    %bs39 : index,
    %bs40 : index,
    %bs41 : index,
    %bs42 : index,
    %bs43 : index,
    %bs44 : index,
    %bs45 : index,
    %bs46 : index,
    %bs47 : index,
    %bs48 : index,
    %bs49 : index,
    %bs50 : index,
    %bs51 : index,
    %bs52 : index,
    %bs53 : index,
    %bs54 : index,
    %bs55 : index,
    %bs56 : index,
    %bs57 : index,
    %bs58 : index,
    %bs59 : index,
    %bs60 : index,
    %bs61 : index,
    %bs62 : index,
    %bs63 : index,
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
    %cs32 : index,
    %cs33 : index,
    %cs34 : index,
    %cs35 : index,
    %cs36 : index,
    %cs37 : index,
    %cs38 : index,
    %cs39 : index,
    %cs40 : index,
    %cs41 : index,
    %cs42 : index,
    %cs43 : index,
    %cs44 : index,
    %cs45 : index,
    %cs46 : index,
    %cs47 : index,
    %cs48 : index,
    %cs49 : index,
    %cs50 : index,
    %cs51 : index,
    %cs52 : index,
    %cs53 : index,
    %cs54 : index,
    %cs55 : index,
    %cs56 : index,
    %cs57 : index,
    %cs58 : index,
    %cs59 : index,
    %cs60 : index,
    %cs61 : index,
    %cs62 : index,
    %cs63 : index,
    %A : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>,
    %B : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>,
    %C : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>)
    #types[
      %A : #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31], f32, offset: 0, strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7, %as8, %as9, %as10, %as11, %as12, %as13, %as14, %as15, %as16, %as17, %as18, %as19, %as20, %as21, %as22, %as23, %as24, %as25, %as26, %as27, %as28, %as29, %as30, %as31, %as32, %as33, %as34, %as35, %as36, %as37, %as38, %as39, %as40, %as41, %as42, %as43, %as44, %as45, %as46, %as47, %as48, %as49, %as50, %as51, %as52, %as53, %as54, %as55, %as56, %as57, %as58, %as59, %as60, %as61, %as62, %as63]>,
      %B : #memref<[%k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7, %bs8, %bs9, %bs10, %bs11, %bs12, %bs13, %bs14, %bs15, %bs16, %bs17, %bs18, %bs19, %bs20, %bs21, %bs22, %bs23, %bs24, %bs25, %bs26, %bs27, %bs28, %bs29, %bs30, %bs31, %bs32, %bs33, %bs34, %bs35, %bs36, %bs37, %bs38, %bs39, %bs40, %bs41, %bs42, %bs43, %bs44, %bs45, %bs46, %bs47, %bs48, %bs49, %bs50, %bs51, %bs52, %bs53, %bs54, %bs55, %bs56, %bs57, %bs58, %bs59, %bs60, %bs61, %bs62, %bs63]>,
      %C : #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7, %cs8, %cs9, %cs10, %cs11, %cs12, %cs13, %cs14, %cs15, %cs16, %cs17, %cs18, %cs19, %cs20, %cs21, %cs22, %cs23, %cs24, %cs25, %cs26, %cs27, %cs28, %cs29, %cs30, %cs31, %cs32, %cs33, %cs34, %cs35, %cs36, %cs37, %cs38, %cs39, %cs40, %cs41, %cs42, %cs43, %cs44, %cs45, %cs46, %cs47, %cs48, %cs49, %cs50, %cs51, %cs52, %cs53, %cs54, %cs55, %cs56, %cs57, %cs58, %cs59, %cs60, %cs61, %cs62, %cs63]>
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
                                  scf.for %ia16 = %c0 to %a16 step %c1 {
                                    scf.for %ia17 = %c0 to %a17 step %c1 {
                                      scf.for %ia18 = %c0 to %a18 step %c1 {
                                        scf.for %ia19 = %c0 to %a19 step %c1 {
                                          scf.for %ia20 = %c0 to %a20 step %c1 {
                                            scf.for %ia21 = %c0 to %a21 step %c1 {
                                              scf.for %ia22 = %c0 to %a22 step %c1 {
                                                scf.for %ia23 = %c0 to %a23 step %c1 {
                                                  scf.for %ia24 = %c0 to %a24 step %c1 {
                                                    scf.for %ia25 = %c0 to %a25 step %c1 {
                                                      scf.for %ia26 = %c0 to %a26 step %c1 {
                                                        scf.for %ia27 = %c0 to %a27 step %c1 {
                                                          scf.for %ia28 = %c0 to %a28 step %c1 {
                                                            scf.for %ia29 = %c0 to %a29 step %c1 {
                                                              scf.for %ia30 = %c0 to %a30 step %c1 {
                                                                scf.for %ia31 = %c0 to %a31 step %c1 {
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
                                                                                                  scf.for %ib16 = %c0 to %b16 step %c1 {
                                                                                                    scf.for %ib17 = %c0 to %b17 step %c1 {
                                                                                                      scf.for %ib18 = %c0 to %b18 step %c1 {
                                                                                                        scf.for %ib19 = %c0 to %b19 step %c1 {
                                                                                                          scf.for %ib20 = %c0 to %b20 step %c1 {
                                                                                                            scf.for %ib21 = %c0 to %b21 step %c1 {
                                                                                                              scf.for %ib22 = %c0 to %b22 step %c1 {
                                                                                                                scf.for %ib23 = %c0 to %b23 step %c1 {
                                                                                                                  scf.for %ib24 = %c0 to %b24 step %c1 {
                                                                                                                    scf.for %ib25 = %c0 to %b25 step %c1 {
                                                                                                                      scf.for %ib26 = %c0 to %b26 step %c1 {
                                                                                                                        scf.for %ib27 = %c0 to %b27 step %c1 {
                                                                                                                          scf.for %ib28 = %c0 to %b28 step %c1 {
                                                                                                                            scf.for %ib29 = %c0 to %b29 step %c1 {
                                                                                                                              scf.for %ib30 = %c0 to %b30 step %c1 {
                                                                                                                                scf.for %ib31 = %c0 to %b31 step %c1 {
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
                                                                                                                                                                  %sum16 = scf.for %ik16 = %c0 to %k16 step %c1 iter_args(%acc16 = %acc15) -> (f32) {
                                                                                                                                                                    %sum17 = scf.for %ik17 = %c0 to %k17 step %c1 iter_args(%acc17 = %acc16) -> (f32) {
                                                                                                                                                                      %sum18 = scf.for %ik18 = %c0 to %k18 step %c1 iter_args(%acc18 = %acc17) -> (f32) {
                                                                                                                                                                        %sum19 = scf.for %ik19 = %c0 to %k19 step %c1 iter_args(%acc19 = %acc18) -> (f32) {
                                                                                                                                                                          %sum20 = scf.for %ik20 = %c0 to %k20 step %c1 iter_args(%acc20 = %acc19) -> (f32) {
                                                                                                                                                                            %sum21 = scf.for %ik21 = %c0 to %k21 step %c1 iter_args(%acc21 = %acc20) -> (f32) {
                                                                                                                                                                              %sum22 = scf.for %ik22 = %c0 to %k22 step %c1 iter_args(%acc22 = %acc21) -> (f32) {
                                                                                                                                                                                %sum23 = scf.for %ik23 = %c0 to %k23 step %c1 iter_args(%acc23 = %acc22) -> (f32) {
                                                                                                                                                                                  %sum24 = scf.for %ik24 = %c0 to %k24 step %c1 iter_args(%acc24 = %acc23) -> (f32) {
                                                                                                                                                                                    %sum25 = scf.for %ik25 = %c0 to %k25 step %c1 iter_args(%acc25 = %acc24) -> (f32) {
                                                                                                                                                                                      %sum26 = scf.for %ik26 = %c0 to %k26 step %c1 iter_args(%acc26 = %acc25) -> (f32) {
                                                                                                                                                                                        %sum27 = scf.for %ik27 = %c0 to %k27 step %c1 iter_args(%acc27 = %acc26) -> (f32) {
                                                                                                                                                                                          %sum28 = scf.for %ik28 = %c0 to %k28 step %c1 iter_args(%acc28 = %acc27) -> (f32) {
                                                                                                                                                                                            %sum29 = scf.for %ik29 = %c0 to %k29 step %c1 iter_args(%acc29 = %acc28) -> (f32) {
                                                                                                                                                                                              %sum30 = scf.for %ik30 = %c0 to %k30 step %c1 iter_args(%acc30 = %acc29) -> (f32) {
                                                                                                                                                                                                %sum31 = scf.for %ik31 = %c0 to %k31 step %c1 iter_args(%acc31 = %acc30) -> (f32) {
                                                                                                                                                                                                  %lhs = dependent_memref.load %A[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ia16, %ia17, %ia18, %ia19, %ia20, %ia21, %ia22, %ia23, %ia24, %ia25, %ia26, %ia27, %ia28, %ia29, %ia30, %ia31, %ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15, %ik16, %ik17, %ik18, %ik19, %ik20, %ik21, %ik22, %ik23, %ik24, %ik25, %ik26, %ik27, %ik28, %ik29, %ik30, %ik31] #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31], f32, offset: 0, strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7, %as8, %as9, %as10, %as11, %as12, %as13, %as14, %as15, %as16, %as17, %as18, %as19, %as20, %as21, %as22, %as23, %as24, %as25, %as26, %as27, %as28, %as29, %as30, %as31, %as32, %as33, %as34, %as35, %as36, %as37, %as38, %as39, %as40, %as41, %as42, %as43, %as44, %as45, %as46, %as47, %as48, %as49, %as50, %as51, %as52, %as53, %as54, %as55, %as56, %as57, %as58, %as59, %as60, %as61, %as62, %as63]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
                                                                                                                                                                                                  %rhs = dependent_memref.load %B[%ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15, %ik16, %ik17, %ik18, %ik19, %ik20, %ik21, %ik22, %ik23, %ik24, %ik25, %ik26, %ik27, %ik28, %ik29, %ik30, %ik31, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15, %ib16, %ib17, %ib18, %ib19, %ib20, %ib21, %ib22, %ib23, %ib24, %ib25, %ib26, %ib27, %ib28, %ib29, %ib30, %ib31] #memref<[%k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31], f32, offset: 0, strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7, %bs8, %bs9, %bs10, %bs11, %bs12, %bs13, %bs14, %bs15, %bs16, %bs17, %bs18, %bs19, %bs20, %bs21, %bs22, %bs23, %bs24, %bs25, %bs26, %bs27, %bs28, %bs29, %bs30, %bs31, %bs32, %bs33, %bs34, %bs35, %bs36, %bs37, %bs38, %bs39, %bs40, %bs41, %bs42, %bs43, %bs44, %bs45, %bs46, %bs47, %bs48, %bs49, %bs50, %bs51, %bs52, %bs53, %bs54, %bs55, %bs56, %bs57, %bs58, %bs59, %bs60, %bs61, %bs62, %bs63]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
                                                                                                                                                                                                  %mul = arith.mulf %lhs, %rhs : f32
                                                                                                                                                                                                  %next = arith.addf %acc31, %mul : f32
                                                                                                                                                                                                  scf.yield %next : f32
                                                                                                                                                                                                }
                                                                                                                                                                                                scf.yield %sum31 : f32
                                                                                                                                                                                              }
                                                                                                                                                                                              scf.yield %sum30 : f32
                                                                                                                                                                                            }
                                                                                                                                                                                            scf.yield %sum29 : f32
                                                                                                                                                                                          }
                                                                                                                                                                                          scf.yield %sum28 : f32
                                                                                                                                                                                        }
                                                                                                                                                                                        scf.yield %sum27 : f32
                                                                                                                                                                                      }
                                                                                                                                                                                      scf.yield %sum26 : f32
                                                                                                                                                                                    }
                                                                                                                                                                                    scf.yield %sum25 : f32
                                                                                                                                                                                  }
                                                                                                                                                                                  scf.yield %sum24 : f32
                                                                                                                                                                                }
                                                                                                                                                                                scf.yield %sum23 : f32
                                                                                                                                                                              }
                                                                                                                                                                              scf.yield %sum22 : f32
                                                                                                                                                                            }
                                                                                                                                                                            scf.yield %sum21 : f32
                                                                                                                                                                          }
                                                                                                                                                                          scf.yield %sum20 : f32
                                                                                                                                                                        }
                                                                                                                                                                        scf.yield %sum19 : f32
                                                                                                                                                                      }
                                                                                                                                                                      scf.yield %sum18 : f32
                                                                                                                                                                    }
                                                                                                                                                                    scf.yield %sum17 : f32
                                                                                                                                                                  }
                                                                                                                                                                  scf.yield %sum16 : f32
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
                                                                                                                                  dependent_memref.store %sum0, %C[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ia16, %ia17, %ia18, %ia19, %ia20, %ia21, %ia22, %ia23, %ia24, %ia25, %ia26, %ia27, %ia28, %ia29, %ia30, %ia31, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15, %ib16, %ib17, %ib18, %ib19, %ib20, %ib21, %ib22, %ib23, %ib24, %ib25, %ib26, %ib27, %ib28, %ib29, %ib30, %ib31] #memref<[%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31], f32, offset: 0, strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7, %cs8, %cs9, %cs10, %cs11, %cs12, %cs13, %cs14, %cs15, %cs16, %cs17, %cs18, %cs19, %cs20, %cs21, %cs22, %cs23, %cs24, %cs25, %cs26, %cs27, %cs28, %cs29, %cs30, %cs31, %cs32, %cs33, %cs34, %cs35, %cs36, %cs37, %cs38, %cs39, %cs40, %cs41, %cs42, %cs43, %cs44, %cs45, %cs46, %cs47, %cs48, %cs49, %cs50, %cs51, %cs52, %cs53, %cs54, %cs55, %cs56, %cs57, %cs58, %cs59, %cs60, %cs61, %cs62, %cs63]> : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32>
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
