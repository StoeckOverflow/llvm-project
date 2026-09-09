func.func @baseline_memref_contraction_rank_64(
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
    %a32 : index,
    %a33 : index,
    %a34 : index,
    %a35 : index,
    %a36 : index,
    %a37 : index,
    %a38 : index,
    %a39 : index,
    %a40 : index,
    %a41 : index,
    %a42 : index,
    %a43 : index,
    %a44 : index,
    %a45 : index,
    %a46 : index,
    %a47 : index,
    %a48 : index,
    %a49 : index,
    %a50 : index,
    %a51 : index,
    %a52 : index,
    %a53 : index,
    %a54 : index,
    %a55 : index,
    %a56 : index,
    %a57 : index,
    %a58 : index,
    %a59 : index,
    %a60 : index,
    %a61 : index,
    %a62 : index,
    %a63 : index,
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
    %b32 : index,
    %b33 : index,
    %b34 : index,
    %b35 : index,
    %b36 : index,
    %b37 : index,
    %b38 : index,
    %b39 : index,
    %b40 : index,
    %b41 : index,
    %b42 : index,
    %b43 : index,
    %b44 : index,
    %b45 : index,
    %b46 : index,
    %b47 : index,
    %b48 : index,
    %b49 : index,
    %b50 : index,
    %b51 : index,
    %b52 : index,
    %b53 : index,
    %b54 : index,
    %b55 : index,
    %b56 : index,
    %b57 : index,
    %b58 : index,
    %b59 : index,
    %b60 : index,
    %b61 : index,
    %b62 : index,
    %b63 : index,
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
    %k32 : index,
    %k33 : index,
    %k34 : index,
    %k35 : index,
    %k36 : index,
    %k37 : index,
    %k38 : index,
    %k39 : index,
    %k40 : index,
    %k41 : index,
    %k42 : index,
    %k43 : index,
    %k44 : index,
    %k45 : index,
    %k46 : index,
    %k47 : index,
    %k48 : index,
    %k49 : index,
    %k50 : index,
    %k51 : index,
    %k52 : index,
    %k53 : index,
    %k54 : index,
    %k55 : index,
    %k56 : index,
    %k57 : index,
    %k58 : index,
    %k59 : index,
    %k60 : index,
    %k61 : index,
    %k62 : index,
    %k63 : index,
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
    %as64 : index,
    %as65 : index,
    %as66 : index,
    %as67 : index,
    %as68 : index,
    %as69 : index,
    %as70 : index,
    %as71 : index,
    %as72 : index,
    %as73 : index,
    %as74 : index,
    %as75 : index,
    %as76 : index,
    %as77 : index,
    %as78 : index,
    %as79 : index,
    %as80 : index,
    %as81 : index,
    %as82 : index,
    %as83 : index,
    %as84 : index,
    %as85 : index,
    %as86 : index,
    %as87 : index,
    %as88 : index,
    %as89 : index,
    %as90 : index,
    %as91 : index,
    %as92 : index,
    %as93 : index,
    %as94 : index,
    %as95 : index,
    %as96 : index,
    %as97 : index,
    %as98 : index,
    %as99 : index,
    %as100 : index,
    %as101 : index,
    %as102 : index,
    %as103 : index,
    %as104 : index,
    %as105 : index,
    %as106 : index,
    %as107 : index,
    %as108 : index,
    %as109 : index,
    %as110 : index,
    %as111 : index,
    %as112 : index,
    %as113 : index,
    %as114 : index,
    %as115 : index,
    %as116 : index,
    %as117 : index,
    %as118 : index,
    %as119 : index,
    %as120 : index,
    %as121 : index,
    %as122 : index,
    %as123 : index,
    %as124 : index,
    %as125 : index,
    %as126 : index,
    %as127 : index,
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
    %bs64 : index,
    %bs65 : index,
    %bs66 : index,
    %bs67 : index,
    %bs68 : index,
    %bs69 : index,
    %bs70 : index,
    %bs71 : index,
    %bs72 : index,
    %bs73 : index,
    %bs74 : index,
    %bs75 : index,
    %bs76 : index,
    %bs77 : index,
    %bs78 : index,
    %bs79 : index,
    %bs80 : index,
    %bs81 : index,
    %bs82 : index,
    %bs83 : index,
    %bs84 : index,
    %bs85 : index,
    %bs86 : index,
    %bs87 : index,
    %bs88 : index,
    %bs89 : index,
    %bs90 : index,
    %bs91 : index,
    %bs92 : index,
    %bs93 : index,
    %bs94 : index,
    %bs95 : index,
    %bs96 : index,
    %bs97 : index,
    %bs98 : index,
    %bs99 : index,
    %bs100 : index,
    %bs101 : index,
    %bs102 : index,
    %bs103 : index,
    %bs104 : index,
    %bs105 : index,
    %bs106 : index,
    %bs107 : index,
    %bs108 : index,
    %bs109 : index,
    %bs110 : index,
    %bs111 : index,
    %bs112 : index,
    %bs113 : index,
    %bs114 : index,
    %bs115 : index,
    %bs116 : index,
    %bs117 : index,
    %bs118 : index,
    %bs119 : index,
    %bs120 : index,
    %bs121 : index,
    %bs122 : index,
    %bs123 : index,
    %bs124 : index,
    %bs125 : index,
    %bs126 : index,
    %bs127 : index,
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
    %cs64 : index,
    %cs65 : index,
    %cs66 : index,
    %cs67 : index,
    %cs68 : index,
    %cs69 : index,
    %cs70 : index,
    %cs71 : index,
    %cs72 : index,
    %cs73 : index,
    %cs74 : index,
    %cs75 : index,
    %cs76 : index,
    %cs77 : index,
    %cs78 : index,
    %cs79 : index,
    %cs80 : index,
    %cs81 : index,
    %cs82 : index,
    %cs83 : index,
    %cs84 : index,
    %cs85 : index,
    %cs86 : index,
    %cs87 : index,
    %cs88 : index,
    %cs89 : index,
    %cs90 : index,
    %cs91 : index,
    %cs92 : index,
    %cs93 : index,
    %cs94 : index,
    %cs95 : index,
    %cs96 : index,
    %cs97 : index,
    %cs98 : index,
    %cs99 : index,
    %cs100 : index,
    %cs101 : index,
    %cs102 : index,
    %cs103 : index,
    %cs104 : index,
    %cs105 : index,
    %cs106 : index,
    %cs107 : index,
    %cs108 : index,
    %cs109 : index,
    %cs110 : index,
    %cs111 : index,
    %cs112 : index,
    %cs113 : index,
    %cs114 : index,
    %cs115 : index,
    %cs116 : index,
    %cs117 : index,
    %cs118 : index,
    %cs119 : index,
    %cs120 : index,
    %cs121 : index,
    %cs122 : index,
    %cs123 : index,
    %cs124 : index,
    %cs125 : index,
    %cs126 : index,
    %cs127 : index,
    %A_flat : memref<?xf32>,
    %B_flat : memref<?xf32>,
    %C_flat : memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %A = memref.reinterpret_cast %A_flat to offset: [0], sizes: [%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %a32, %a33, %a34, %a35, %a36, %a37, %a38, %a39, %a40, %a41, %a42, %a43, %a44, %a45, %a46, %a47, %a48, %a49, %a50, %a51, %a52, %a53, %a54, %a55, %a56, %a57, %a58, %a59, %a60, %a61, %a62, %a63, %k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31, %k32, %k33, %k34, %k35, %k36, %k37, %k38, %k39, %k40, %k41, %k42, %k43, %k44, %k45, %k46, %k47, %k48, %k49, %k50, %k51, %k52, %k53, %k54, %k55, %k56, %k57, %k58, %k59, %k60, %k61, %k62, %k63], strides: [%as0, %as1, %as2, %as3, %as4, %as5, %as6, %as7, %as8, %as9, %as10, %as11, %as12, %as13, %as14, %as15, %as16, %as17, %as18, %as19, %as20, %as21, %as22, %as23, %as24, %as25, %as26, %as27, %as28, %as29, %as30, %as31, %as32, %as33, %as34, %as35, %as36, %as37, %as38, %as39, %as40, %as41, %as42, %as43, %as44, %as45, %as46, %as47, %as48, %as49, %as50, %as51, %as52, %as53, %as54, %as55, %as56, %as57, %as58, %as59, %as60, %as61, %as62, %as63, %as64, %as65, %as66, %as67, %as68, %as69, %as70, %as71, %as72, %as73, %as74, %as75, %as76, %as77, %as78, %as79, %as80, %as81, %as82, %as83, %as84, %as85, %as86, %as87, %as88, %as89, %as90, %as91, %as92, %as93, %as94, %as95, %as96, %as97, %as98, %as99, %as100, %as101, %as102, %as103, %as104, %as105, %as106, %as107, %as108, %as109, %as110, %as111, %as112, %as113, %as114, %as115, %as116, %as117, %as118, %as119, %as120, %as121, %as122, %as123, %as124, %as125, %as126, %as127] : memref<?xf32> to memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
  %B = memref.reinterpret_cast %B_flat to offset: [0], sizes: [%k0, %k1, %k2, %k3, %k4, %k5, %k6, %k7, %k8, %k9, %k10, %k11, %k12, %k13, %k14, %k15, %k16, %k17, %k18, %k19, %k20, %k21, %k22, %k23, %k24, %k25, %k26, %k27, %k28, %k29, %k30, %k31, %k32, %k33, %k34, %k35, %k36, %k37, %k38, %k39, %k40, %k41, %k42, %k43, %k44, %k45, %k46, %k47, %k48, %k49, %k50, %k51, %k52, %k53, %k54, %k55, %k56, %k57, %k58, %k59, %k60, %k61, %k62, %k63, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31, %b32, %b33, %b34, %b35, %b36, %b37, %b38, %b39, %b40, %b41, %b42, %b43, %b44, %b45, %b46, %b47, %b48, %b49, %b50, %b51, %b52, %b53, %b54, %b55, %b56, %b57, %b58, %b59, %b60, %b61, %b62, %b63], strides: [%bs0, %bs1, %bs2, %bs3, %bs4, %bs5, %bs6, %bs7, %bs8, %bs9, %bs10, %bs11, %bs12, %bs13, %bs14, %bs15, %bs16, %bs17, %bs18, %bs19, %bs20, %bs21, %bs22, %bs23, %bs24, %bs25, %bs26, %bs27, %bs28, %bs29, %bs30, %bs31, %bs32, %bs33, %bs34, %bs35, %bs36, %bs37, %bs38, %bs39, %bs40, %bs41, %bs42, %bs43, %bs44, %bs45, %bs46, %bs47, %bs48, %bs49, %bs50, %bs51, %bs52, %bs53, %bs54, %bs55, %bs56, %bs57, %bs58, %bs59, %bs60, %bs61, %bs62, %bs63, %bs64, %bs65, %bs66, %bs67, %bs68, %bs69, %bs70, %bs71, %bs72, %bs73, %bs74, %bs75, %bs76, %bs77, %bs78, %bs79, %bs80, %bs81, %bs82, %bs83, %bs84, %bs85, %bs86, %bs87, %bs88, %bs89, %bs90, %bs91, %bs92, %bs93, %bs94, %bs95, %bs96, %bs97, %bs98, %bs99, %bs100, %bs101, %bs102, %bs103, %bs104, %bs105, %bs106, %bs107, %bs108, %bs109, %bs110, %bs111, %bs112, %bs113, %bs114, %bs115, %bs116, %bs117, %bs118, %bs119, %bs120, %bs121, %bs122, %bs123, %bs124, %bs125, %bs126, %bs127] : memref<?xf32> to memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
  %C = memref.reinterpret_cast %C_flat to offset: [0], sizes: [%a0, %a1, %a2, %a3, %a4, %a5, %a6, %a7, %a8, %a9, %a10, %a11, %a12, %a13, %a14, %a15, %a16, %a17, %a18, %a19, %a20, %a21, %a22, %a23, %a24, %a25, %a26, %a27, %a28, %a29, %a30, %a31, %a32, %a33, %a34, %a35, %a36, %a37, %a38, %a39, %a40, %a41, %a42, %a43, %a44, %a45, %a46, %a47, %a48, %a49, %a50, %a51, %a52, %a53, %a54, %a55, %a56, %a57, %a58, %a59, %a60, %a61, %a62, %a63, %b0, %b1, %b2, %b3, %b4, %b5, %b6, %b7, %b8, %b9, %b10, %b11, %b12, %b13, %b14, %b15, %b16, %b17, %b18, %b19, %b20, %b21, %b22, %b23, %b24, %b25, %b26, %b27, %b28, %b29, %b30, %b31, %b32, %b33, %b34, %b35, %b36, %b37, %b38, %b39, %b40, %b41, %b42, %b43, %b44, %b45, %b46, %b47, %b48, %b49, %b50, %b51, %b52, %b53, %b54, %b55, %b56, %b57, %b58, %b59, %b60, %b61, %b62, %b63], strides: [%cs0, %cs1, %cs2, %cs3, %cs4, %cs5, %cs6, %cs7, %cs8, %cs9, %cs10, %cs11, %cs12, %cs13, %cs14, %cs15, %cs16, %cs17, %cs18, %cs19, %cs20, %cs21, %cs22, %cs23, %cs24, %cs25, %cs26, %cs27, %cs28, %cs29, %cs30, %cs31, %cs32, %cs33, %cs34, %cs35, %cs36, %cs37, %cs38, %cs39, %cs40, %cs41, %cs42, %cs43, %cs44, %cs45, %cs46, %cs47, %cs48, %cs49, %cs50, %cs51, %cs52, %cs53, %cs54, %cs55, %cs56, %cs57, %cs58, %cs59, %cs60, %cs61, %cs62, %cs63, %cs64, %cs65, %cs66, %cs67, %cs68, %cs69, %cs70, %cs71, %cs72, %cs73, %cs74, %cs75, %cs76, %cs77, %cs78, %cs79, %cs80, %cs81, %cs82, %cs83, %cs84, %cs85, %cs86, %cs87, %cs88, %cs89, %cs90, %cs91, %cs92, %cs93, %cs94, %cs95, %cs96, %cs97, %cs98, %cs99, %cs100, %cs101, %cs102, %cs103, %cs104, %cs105, %cs106, %cs107, %cs108, %cs109, %cs110, %cs111, %cs112, %cs113, %cs114, %cs115, %cs116, %cs117, %cs118, %cs119, %cs120, %cs121, %cs122, %cs123, %cs124, %cs125, %cs126, %cs127] : memref<?xf32> to memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
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
                                                                  scf.for %ia32 = %c0 to %a32 step %c1 {
                                                                    scf.for %ia33 = %c0 to %a33 step %c1 {
                                                                      scf.for %ia34 = %c0 to %a34 step %c1 {
                                                                        scf.for %ia35 = %c0 to %a35 step %c1 {
                                                                          scf.for %ia36 = %c0 to %a36 step %c1 {
                                                                            scf.for %ia37 = %c0 to %a37 step %c1 {
                                                                              scf.for %ia38 = %c0 to %a38 step %c1 {
                                                                                scf.for %ia39 = %c0 to %a39 step %c1 {
                                                                                  scf.for %ia40 = %c0 to %a40 step %c1 {
                                                                                    scf.for %ia41 = %c0 to %a41 step %c1 {
                                                                                      scf.for %ia42 = %c0 to %a42 step %c1 {
                                                                                        scf.for %ia43 = %c0 to %a43 step %c1 {
                                                                                          scf.for %ia44 = %c0 to %a44 step %c1 {
                                                                                            scf.for %ia45 = %c0 to %a45 step %c1 {
                                                                                              scf.for %ia46 = %c0 to %a46 step %c1 {
                                                                                                scf.for %ia47 = %c0 to %a47 step %c1 {
                                                                                                  scf.for %ia48 = %c0 to %a48 step %c1 {
                                                                                                    scf.for %ia49 = %c0 to %a49 step %c1 {
                                                                                                      scf.for %ia50 = %c0 to %a50 step %c1 {
                                                                                                        scf.for %ia51 = %c0 to %a51 step %c1 {
                                                                                                          scf.for %ia52 = %c0 to %a52 step %c1 {
                                                                                                            scf.for %ia53 = %c0 to %a53 step %c1 {
                                                                                                              scf.for %ia54 = %c0 to %a54 step %c1 {
                                                                                                                scf.for %ia55 = %c0 to %a55 step %c1 {
                                                                                                                  scf.for %ia56 = %c0 to %a56 step %c1 {
                                                                                                                    scf.for %ia57 = %c0 to %a57 step %c1 {
                                                                                                                      scf.for %ia58 = %c0 to %a58 step %c1 {
                                                                                                                        scf.for %ia59 = %c0 to %a59 step %c1 {
                                                                                                                          scf.for %ia60 = %c0 to %a60 step %c1 {
                                                                                                                            scf.for %ia61 = %c0 to %a61 step %c1 {
                                                                                                                              scf.for %ia62 = %c0 to %a62 step %c1 {
                                                                                                                                scf.for %ia63 = %c0 to %a63 step %c1 {
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
                                                                                                                                                                                                  scf.for %ib32 = %c0 to %b32 step %c1 {
                                                                                                                                                                                                    scf.for %ib33 = %c0 to %b33 step %c1 {
                                                                                                                                                                                                      scf.for %ib34 = %c0 to %b34 step %c1 {
                                                                                                                                                                                                        scf.for %ib35 = %c0 to %b35 step %c1 {
                                                                                                                                                                                                          scf.for %ib36 = %c0 to %b36 step %c1 {
                                                                                                                                                                                                            scf.for %ib37 = %c0 to %b37 step %c1 {
                                                                                                                                                                                                              scf.for %ib38 = %c0 to %b38 step %c1 {
                                                                                                                                                                                                                scf.for %ib39 = %c0 to %b39 step %c1 {
                                                                                                                                                                                                                  scf.for %ib40 = %c0 to %b40 step %c1 {
                                                                                                                                                                                                                    scf.for %ib41 = %c0 to %b41 step %c1 {
                                                                                                                                                                                                                      scf.for %ib42 = %c0 to %b42 step %c1 {
                                                                                                                                                                                                                        scf.for %ib43 = %c0 to %b43 step %c1 {
                                                                                                                                                                                                                          scf.for %ib44 = %c0 to %b44 step %c1 {
                                                                                                                                                                                                                            scf.for %ib45 = %c0 to %b45 step %c1 {
                                                                                                                                                                                                                              scf.for %ib46 = %c0 to %b46 step %c1 {
                                                                                                                                                                                                                                scf.for %ib47 = %c0 to %b47 step %c1 {
                                                                                                                                                                                                                                  scf.for %ib48 = %c0 to %b48 step %c1 {
                                                                                                                                                                                                                                    scf.for %ib49 = %c0 to %b49 step %c1 {
                                                                                                                                                                                                                                      scf.for %ib50 = %c0 to %b50 step %c1 {
                                                                                                                                                                                                                                        scf.for %ib51 = %c0 to %b51 step %c1 {
                                                                                                                                                                                                                                          scf.for %ib52 = %c0 to %b52 step %c1 {
                                                                                                                                                                                                                                            scf.for %ib53 = %c0 to %b53 step %c1 {
                                                                                                                                                                                                                                              scf.for %ib54 = %c0 to %b54 step %c1 {
                                                                                                                                                                                                                                                scf.for %ib55 = %c0 to %b55 step %c1 {
                                                                                                                                                                                                                                                  scf.for %ib56 = %c0 to %b56 step %c1 {
                                                                                                                                                                                                                                                    scf.for %ib57 = %c0 to %b57 step %c1 {
                                                                                                                                                                                                                                                      scf.for %ib58 = %c0 to %b58 step %c1 {
                                                                                                                                                                                                                                                        scf.for %ib59 = %c0 to %b59 step %c1 {
                                                                                                                                                                                                                                                          scf.for %ib60 = %c0 to %b60 step %c1 {
                                                                                                                                                                                                                                                            scf.for %ib61 = %c0 to %b61 step %c1 {
                                                                                                                                                                                                                                                              scf.for %ib62 = %c0 to %b62 step %c1 {
                                                                                                                                                                                                                                                                scf.for %ib63 = %c0 to %b63 step %c1 {
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
                                                                                                                                                                                                                                                                                                                                  %sum32 = scf.for %ik32 = %c0 to %k32 step %c1 iter_args(%acc32 = %acc31) -> (f32) {
                                                                                                                                                                                                                                                                                                                                    %sum33 = scf.for %ik33 = %c0 to %k33 step %c1 iter_args(%acc33 = %acc32) -> (f32) {
                                                                                                                                                                                                                                                                                                                                      %sum34 = scf.for %ik34 = %c0 to %k34 step %c1 iter_args(%acc34 = %acc33) -> (f32) {
                                                                                                                                                                                                                                                                                                                                        %sum35 = scf.for %ik35 = %c0 to %k35 step %c1 iter_args(%acc35 = %acc34) -> (f32) {
                                                                                                                                                                                                                                                                                                                                          %sum36 = scf.for %ik36 = %c0 to %k36 step %c1 iter_args(%acc36 = %acc35) -> (f32) {
                                                                                                                                                                                                                                                                                                                                            %sum37 = scf.for %ik37 = %c0 to %k37 step %c1 iter_args(%acc37 = %acc36) -> (f32) {
                                                                                                                                                                                                                                                                                                                                              %sum38 = scf.for %ik38 = %c0 to %k38 step %c1 iter_args(%acc38 = %acc37) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                %sum39 = scf.for %ik39 = %c0 to %k39 step %c1 iter_args(%acc39 = %acc38) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                  %sum40 = scf.for %ik40 = %c0 to %k40 step %c1 iter_args(%acc40 = %acc39) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                    %sum41 = scf.for %ik41 = %c0 to %k41 step %c1 iter_args(%acc41 = %acc40) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                      %sum42 = scf.for %ik42 = %c0 to %k42 step %c1 iter_args(%acc42 = %acc41) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                        %sum43 = scf.for %ik43 = %c0 to %k43 step %c1 iter_args(%acc43 = %acc42) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                          %sum44 = scf.for %ik44 = %c0 to %k44 step %c1 iter_args(%acc44 = %acc43) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                            %sum45 = scf.for %ik45 = %c0 to %k45 step %c1 iter_args(%acc45 = %acc44) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                              %sum46 = scf.for %ik46 = %c0 to %k46 step %c1 iter_args(%acc46 = %acc45) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                %sum47 = scf.for %ik47 = %c0 to %k47 step %c1 iter_args(%acc47 = %acc46) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                  %sum48 = scf.for %ik48 = %c0 to %k48 step %c1 iter_args(%acc48 = %acc47) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                    %sum49 = scf.for %ik49 = %c0 to %k49 step %c1 iter_args(%acc49 = %acc48) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                      %sum50 = scf.for %ik50 = %c0 to %k50 step %c1 iter_args(%acc50 = %acc49) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                        %sum51 = scf.for %ik51 = %c0 to %k51 step %c1 iter_args(%acc51 = %acc50) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                          %sum52 = scf.for %ik52 = %c0 to %k52 step %c1 iter_args(%acc52 = %acc51) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                            %sum53 = scf.for %ik53 = %c0 to %k53 step %c1 iter_args(%acc53 = %acc52) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                              %sum54 = scf.for %ik54 = %c0 to %k54 step %c1 iter_args(%acc54 = %acc53) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                %sum55 = scf.for %ik55 = %c0 to %k55 step %c1 iter_args(%acc55 = %acc54) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                  %sum56 = scf.for %ik56 = %c0 to %k56 step %c1 iter_args(%acc56 = %acc55) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                    %sum57 = scf.for %ik57 = %c0 to %k57 step %c1 iter_args(%acc57 = %acc56) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                      %sum58 = scf.for %ik58 = %c0 to %k58 step %c1 iter_args(%acc58 = %acc57) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                        %sum59 = scf.for %ik59 = %c0 to %k59 step %c1 iter_args(%acc59 = %acc58) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                          %sum60 = scf.for %ik60 = %c0 to %k60 step %c1 iter_args(%acc60 = %acc59) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                            %sum61 = scf.for %ik61 = %c0 to %k61 step %c1 iter_args(%acc61 = %acc60) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                              %sum62 = scf.for %ik62 = %c0 to %k62 step %c1 iter_args(%acc62 = %acc61) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                                %sum63 = scf.for %ik63 = %c0 to %k63 step %c1 iter_args(%acc63 = %acc62) -> (f32) {
                                                                                                                                                                                                                                                                                                                                                                                                  %lhs = memref.load %A[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ia16, %ia17, %ia18, %ia19, %ia20, %ia21, %ia22, %ia23, %ia24, %ia25, %ia26, %ia27, %ia28, %ia29, %ia30, %ia31, %ia32, %ia33, %ia34, %ia35, %ia36, %ia37, %ia38, %ia39, %ia40, %ia41, %ia42, %ia43, %ia44, %ia45, %ia46, %ia47, %ia48, %ia49, %ia50, %ia51, %ia52, %ia53, %ia54, %ia55, %ia56, %ia57, %ia58, %ia59, %ia60, %ia61, %ia62, %ia63, %ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15, %ik16, %ik17, %ik18, %ik19, %ik20, %ik21, %ik22, %ik23, %ik24, %ik25, %ik26, %ik27, %ik28, %ik29, %ik30, %ik31, %ik32, %ik33, %ik34, %ik35, %ik36, %ik37, %ik38, %ik39, %ik40, %ik41, %ik42, %ik43, %ik44, %ik45, %ik46, %ik47, %ik48, %ik49, %ik50, %ik51, %ik52, %ik53, %ik54, %ik55, %ik56, %ik57, %ik58, %ik59, %ik60, %ik61, %ik62, %ik63] : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
                                                                                                                                                                                                                                                                                                                                                                                                  %rhs = memref.load %B[%ik0, %ik1, %ik2, %ik3, %ik4, %ik5, %ik6, %ik7, %ik8, %ik9, %ik10, %ik11, %ik12, %ik13, %ik14, %ik15, %ik16, %ik17, %ik18, %ik19, %ik20, %ik21, %ik22, %ik23, %ik24, %ik25, %ik26, %ik27, %ik28, %ik29, %ik30, %ik31, %ik32, %ik33, %ik34, %ik35, %ik36, %ik37, %ik38, %ik39, %ik40, %ik41, %ik42, %ik43, %ik44, %ik45, %ik46, %ik47, %ik48, %ik49, %ik50, %ik51, %ik52, %ik53, %ik54, %ik55, %ik56, %ik57, %ik58, %ik59, %ik60, %ik61, %ik62, %ik63, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15, %ib16, %ib17, %ib18, %ib19, %ib20, %ib21, %ib22, %ib23, %ib24, %ib25, %ib26, %ib27, %ib28, %ib29, %ib30, %ib31, %ib32, %ib33, %ib34, %ib35, %ib36, %ib37, %ib38, %ib39, %ib40, %ib41, %ib42, %ib43, %ib44, %ib45, %ib46, %ib47, %ib48, %ib49, %ib50, %ib51, %ib52, %ib53, %ib54, %ib55, %ib56, %ib57, %ib58, %ib59, %ib60, %ib61, %ib62, %ib63] : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
                                                                                                                                                                                                                                                                                                                                                                                                  %mul = arith.mulf %lhs, %rhs : f32
                                                                                                                                                                                                                                                                                                                                                                                                  %next = arith.addf %acc63, %mul : f32
                                                                                                                                                                                                                                                                                                                                                                                                  scf.yield %next : f32
                                                                                                                                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                                                                                                                                scf.yield %sum63 : f32
                                                                                                                                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                                                                                                                                              scf.yield %sum62 : f32
                                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                                            scf.yield %sum61 : f32
                                                                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                                                                          scf.yield %sum60 : f32
                                                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                                                                        scf.yield %sum59 : f32
                                                                                                                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                                                                                                                                                                                      scf.yield %sum58 : f32
                                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                                    scf.yield %sum57 : f32
                                                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                                                  scf.yield %sum56 : f32
                                                                                                                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                                                                                                                scf.yield %sum55 : f32
                                                                                                                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                                                                                                                              scf.yield %sum54 : f32
                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                            scf.yield %sum53 : f32
                                                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                                                          scf.yield %sum52 : f32
                                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                                                        scf.yield %sum51 : f32
                                                                                                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                                                                                                                                                                      scf.yield %sum50 : f32
                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                    scf.yield %sum49 : f32
                                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                                  scf.yield %sum48 : f32
                                                                                                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                                                                                                scf.yield %sum47 : f32
                                                                                                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                                                                                                              scf.yield %sum46 : f32
                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                            scf.yield %sum45 : f32
                                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                                          scf.yield %sum44 : f32
                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                                        scf.yield %sum43 : f32
                                                                                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                                                                                                                                                      scf.yield %sum42 : f32
                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                    scf.yield %sum41 : f32
                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                  scf.yield %sum40 : f32
                                                                                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                                                                                scf.yield %sum39 : f32
                                                                                                                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                                                                                                              scf.yield %sum38 : f32
                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                            scf.yield %sum37 : f32
                                                                                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                                                                                          scf.yield %sum36 : f32
                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                        scf.yield %sum35 : f32
                                                                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                                                                                                                                      scf.yield %sum34 : f32
                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                    scf.yield %sum33 : f32
                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                  scf.yield %sum32 : f32
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
                                                                                                                                                                                                                                                                  memref.store %sum0, %C[%ia0, %ia1, %ia2, %ia3, %ia4, %ia5, %ia6, %ia7, %ia8, %ia9, %ia10, %ia11, %ia12, %ia13, %ia14, %ia15, %ia16, %ia17, %ia18, %ia19, %ia20, %ia21, %ia22, %ia23, %ia24, %ia25, %ia26, %ia27, %ia28, %ia29, %ia30, %ia31, %ia32, %ia33, %ia34, %ia35, %ia36, %ia37, %ia38, %ia39, %ia40, %ia41, %ia42, %ia43, %ia44, %ia45, %ia46, %ia47, %ia48, %ia49, %ia50, %ia51, %ia52, %ia53, %ia54, %ia55, %ia56, %ia57, %ia58, %ia59, %ia60, %ia61, %ia62, %ia63, %ib0, %ib1, %ib2, %ib3, %ib4, %ib5, %ib6, %ib7, %ib8, %ib9, %ib10, %ib11, %ib12, %ib13, %ib14, %ib15, %ib16, %ib17, %ib18, %ib19, %ib20, %ib21, %ib22, %ib23, %ib24, %ib25, %ib26, %ib27, %ib28, %ib29, %ib30, %ib31, %ib32, %ib33, %ib34, %ib35, %ib36, %ib37, %ib38, %ib39, %ib40, %ib41, %ib42, %ib43, %ib44, %ib45, %ib46, %ib47, %ib48, %ib49, %ib50, %ib51, %ib52, %ib53, %ib54, %ib55, %ib56, %ib57, %ib58, %ib59, %ib60, %ib61, %ib62, %ib63] : memref<?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?x?xf32, strided<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?], offset: ?>>
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
