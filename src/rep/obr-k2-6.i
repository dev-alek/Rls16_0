/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки с признаками

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  if line-counter( Outstream ) + 3 > page-size( Outstream ) then do:
    put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
    page stream OutStream .
    run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
  end.
  if  ( v-row ) >= 63000 then do:
    Output stream Macr_Excel  close .
    /*Запишем в файл параметров */
    run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
    /* создаем временный файл */
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .
  end.

  for each temp-sum where temp-sum.level = -1 :
    assign temp-sum.sum = 0  .
  end.

  assign jj = 1 .
  do ii = 1 to 9 :
    if use-column[ii]  = yes then assign jj = jj + 1 .
  end.
  if use-column[12] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[31] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[50] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[14] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[33] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[15] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh_VP}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[34] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh_VP}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[16] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[35] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[52] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[68] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Ras_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[77] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Ras_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[17] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[36] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[53] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[69] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[78] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Vozvrat_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[18] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[37] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[54] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[70] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[79] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[19] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[38] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[55] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[71] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Ras_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[80] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Ras_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[20] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[39] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[56] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[72] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[81] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[21] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[40] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[57] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[73] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[82] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[22] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[41] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[58] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[74] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[83] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[23] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[42] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[59] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[75] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[84] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[24] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[43] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[60] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[76] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[85] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[25] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Inv}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[44] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Inv}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[61] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Inv}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[26] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Spi_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[45] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Spi_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[62] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Spi_Vnesh}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[27] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[46] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[63] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Pri_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[28] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Ras_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[47] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Ras_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[64] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[29] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Vozvrat_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[48] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Vozvrat_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[65] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Perem}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[30] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Pri_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[49] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Pri_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[66] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Pri_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[86] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, {&TDEDT_Spi_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[87] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, {&TDEDT_Spi_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[88] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Spi_Prvo}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[67] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Overturn}, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[13] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[32] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[51] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[10] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "eff-val", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[11] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "eff-prc", -1, jj ) . assign jj = jj + 1 . end.
  if RADIO-AltObj > 1     then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[6] = yes or use-column[7] = yes  then do:
    define variable smm1 as decimal initial 0 no-undo .
    define variable smm2 as decimal initial 0 no-undo .
    define variable tp  as integer   no-undo .

    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
    no-error .
    if available temp-prt then assign smm2 = temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
    no-error .
    if available temp-prt then assign smm2 = smm2 + temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
    no-error .
    if available temp-prt then assign smm2 = smm2 - temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
    no-error .
    if available temp-prt then assign smm2 = smm2 - temp-prt.sum .
    if use-column[6] = yes then do:
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
      no-error .
      if available temp-prt then assign smm1 = temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
      no-error .
      if available temp-prt then assign smm1 = smm1 + temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      assign gds-prop.Avrg-Sale-Price = smm2 / smm1 .
    end.
    if use-column[7] = yes then do:
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh}
      no-error .
      if available temp-prt then assign smm1 = temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = {&TDEDT_Ras_Vnesh_Kass}
      no-error .
      if available temp-prt then assign smm1 = smm1 + temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh}
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      assign gds-prop.Up-Plan = (smm2 - smm1) * 100 / smm1 .
    end.
  end.

  /* проверка на 0 */
  define variable  null-ostat  as logical initial yes no-undo .
  define variable  null-oborot as logical initial yes no-undo .
  assign NullStr = 0 .

  for each temp-sum where temp-sum.level = -1 and ( temp-sum.doc-type = "ost-beg" or temp-sum.doc-type = "ost-end" ) :
    if temp-sum.sum <> 0 then do:
      assign null-ostat = no .
      leave.
    end.
  end.
  for each temp-sum  where temp-sum.level = -1 and temp-sum.doc-type <> "ost-beg"  and temp-sum.doc-type <> "ost-end" :
    if temp-sum.sum <> 0 then do:
      assign null-oborot = no .
      leave.
    end.
  end.
  if ShowZero = no and ShowZero-2 = no then do: /* ненулевые остатки и обороты */
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 1 .
    end.
    else NullStr = 0 .
  end.
  if ShowZero = yes and ShowZero-2 = no then do: /* нулевые остатки и ненулевые обороты */
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 1 .
    end.
    else do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 0 .
    end.
  end.
  if ShowZero = no and ShowZero-2 = yes then do: /* ненулевые остатки и нулевые обороты */
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 0 .
    end.
    else NullStr = 0 .
  end.

  if NullStr = 0 and SumsOnly = no then do:
    assign  is-prn-titul = yes  .
    run PutTitul in this-procedure .  /* вывод шапок */
    assign
      v-col = 1
      beg   = 1
    .
    if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then do:
      if tog-obj = true then do: /* раздельно по объектам */
        put stream txt-file
          gds-prop.obj-type format "X(5)"   {&tabulation}
          gds-prop.obj-code format ">>>>>>>9" {&tabulation}
          gds-prop.obj-name format "X(50)"   {&tabulation}
        .
      end.
      put stream txt-file
        gds-prop.grp-name format "X(70)"  {&tabulation}
        gds-prop.prod-type format "X(5)"   {&tabulation}
        gds-prop.prod-code format ">>>>>>>>>>>9" {&tabulation}
        gds-prop.prod-name format "X(50)"  {&tabulation}
      .
    end.

    if use-column[1]  = yes then do:
      put stream outstream  "|" at beg gds-prop.b-code format "X(13)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.b-code format "X(13)" {&tabulation}.
      run macr_excel_char (string(gds-prop.b-code), v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 14 .
    end.
    if use-column[2]  = yes then do:
      put stream outstream  "|" at beg gds-prop.artic format "X(16)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.artic format "X(16)" {&tabulation} .
      run macr_excel_char (gds-prop.artic, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 17 .
    end.
    if use-column[3]  = yes then do:
      put stream outstream  "|" at beg gds-prop.gds-name format "X(40)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.gds-name format "X(40)" {&tabulation} .
      run macr_excel_char (gds-prop.gds-name, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 41 .
    end.
    if ExportZUM and (SumsOnly2 or gds-prop.empty-scale)  then put stream txt-file  {&tabulation} .
    if use-column[4]  = yes then do:
      put stream outstream  "|" at beg gds-prop.unit-base format "X(4)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.unit-base format "X(4)" {&tabulation} .
      run macr_excel_char (gds-prop.unit-base, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 5 .
    end.
    if use-column[5]  = yes then do:
      put stream outstream  "|" at beg gds-prop.Cost-Price format ">>>,>>>,>>9.99" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")  {&tabulation} .
      run macr_excel_sum  ( gds-prop.Cost-Price, v-row, v-col, 2) .
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[6]  = yes then do:
      if prod-zen = yes then do:
        put stream outstream  "|" at beg gds-prop.Avrg-Sale-Price format ">>>,>>>,>>9.99" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")  {&tabulation} .
        run macr_excel_sum  ( gds-prop.Avrg-Sale-Price, v-row, v-col, 2) .
      end.
      else do:
        put stream outstream  "|" at beg gds-prop.Last-Sale-Price format ">>>,>>>,>>9.99" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  {&tabulation} .
        run macr_excel_sum  ( gds-prop.Last-Sale-Price, v-row, v-col, 2) .
      end.
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[7]  = yes then do:
      put stream outstream  "|" at beg gds-prop.Up-Plan format "->>,>>>,>>9.99" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")   {&tabulation} .
      run macr_excel_sum  ( gds-prop.Up-Plan, v-row, v-col, 2) .
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[8]  = yes then do:
      if gds-prop.LastPer-Date <> ? then do:
        put stream outstream  "|" at beg gds-prop.LastPer-Date format "99/99/9999" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.LastPer-Date format "99/99/9999" {&tabulation} .
        run macr_excel_char (string(gds-prop.LastPer-Date,"99.99.9999"), v-row, v-col) .
      end.
      assign v-col = v-col + 1    beg = beg + 11 .
    end.
    if use-column[9]  = yes then do:
      put stream outstream  "|" at beg gds-prop.LastPer-Num format "X(10)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.LastPer-Num format "X(10)" {&tabulation} .
      run macr_excel_char (gds-prop.LastPer-Num, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 11 .
    end.

    if SumsOnly2 or gds-prop.empty-scale then do:
      for each temp-sum where temp-sum.level = -1 :
        case temp-sum.sum-type :
          when 0 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-qnty1),".",",")  {&tabulation} .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
            assign  beg = beg + 15 .
          end.
          when 1 or when 2 or when 3 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-sum .
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  {&tabulation} .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
            assign  beg = beg + 15 .
          end.
          when 4 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-prc .
            if ExportZUM then put stream txt-file  UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  {&tabulation} .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
            assign  beg = beg + 10 .
          end.
        end.
        assign v-col = v-col + 1 .
      end.
    end.
    else do:
      for each temp-sum where temp-sum.level = -1 :
        case temp-sum.sum-type :
          when 0 or when 1 or when 2 or when 3 then do:
            put stream outstream  "|" at beg  .     assign  beg = beg + 15 .
          end.
          when 4 then do:
            put stream outstream  "|" at beg  .     assign  beg = beg + 10 .
          end.
        end.
        assign v-col = v-col + 1 .
      end.
    end.
    put stream outstream   "|"  skip .
    if ExportZUM then put stream txt-file  {&new-line} .
    assign v-row = v-row + 1 .
    if name-tov = 3 and use-column[3]  = yes then do:
      assign   v-col = 1     beg   = 1 .
      put stream outstream  "|"  .
      if use-column[1]  = yes then  assign v-col = v-col + 1    beg = beg + 14 .
      if use-column[2]  = yes then  assign v-col = v-col + 1    beg = beg + 17 .
      put stream outstream  "|" at beg gds-prop.gds-name1 format "X(40)"  "|"   "|" at end-sum skip .
      run macr_excel_char (gds-prop.gds-name1, v-row, v-col) .
      assign v-row = v-row + 1 .
    end.

  end.

  if NullStr < 2 then do:    /* проверка на не 0        */
    if tog-obj = true then run CalculSum in this-procedure (2) . /* суммирование по объекту */
    run CalculSum in this-procedure (1) . /* суммирование всего      */
  end.


  /* ********************************************************************************************* */

  /*  А теперь смотрим шкалу */

  /* ********************************************************************************************* */

  if gds-prop.empty-scale = no and NullStr = 0 and SumsOnly = no then do: /* это шкальный товар */
    run PrintScale .
  end.

/* $Workfile$   E n d */