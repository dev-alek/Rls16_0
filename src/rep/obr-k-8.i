/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Чернова Светлана Александровна
Дата создания: 02/11/10
Author: Svetlana Chernova
Creation date: 02/11/10

Автор1: Кочетков Михаил Юрьевич
Дата создания: 03/22/06

*/
  if buf_gds-sum.StartWay-Qnty  <> 0 or buf_gds-sum.StartWay-CostSum <> 0 or buf_gds-sum.StartWay-SaleSum <> 0 or buf_gds-sum.EndWay-Qnty   <> 0 or
     buf_gds-sum.EndWay-CostSum <> 0 or buf_gds-sum.EndWay-SaleSum   <> 0 or buf_gds-sum.InExt-Qnty       <> 0 or buf_gds-sum.InExt-CostSum <> 0 or
     buf_gds-sum.RetPost-Qnty   <> 0 or buf_gds-sum.RetPost-CostSum  <> 0 or buf_gds-sum.OutExt-Qnty      <> 0 or buf_gds-sum.OutExt-CostSum <> 0 or
     buf_gds-sum.OutExt-SaleSum <> 0 or buf_gds-sum.OutExt-DiscntSum <> 0 or buf_gds-sum.RetOut-Qnty      <> 0 or buf_gds-sum.RetOut-CostSum <> 0 or
     buf_gds-sum.RetOut-SaleSum <> 0 or buf_gds-sum.RetOut-DiscntSum <> 0 or buf_gds-sum.OutExtKass-Qnty  <> 0 or buf_gds-sum.OutExtKass-CostSum  <> 0 or
     buf_gds-sum.OutExtKass-SaleSum <> 0 or buf_gds-sum.OutExtKass-DiscntSum <> 0 or buf_gds-sum.RetOutKass-Qnty <> 0 or buf_gds-sum.RetOutKass-CostSum <> 0 or
     buf_gds-sum.RetOutKass-SaleSum <> 0 or buf_gds-sum.RetOutKass-DiscntSum <> 0 or buf_gds-sum.InInt-Qnty      <> 0 or buf_gds-sum.InInt-CostSum      <> 0 or
     buf_gds-sum.InInt-SaleSum      <> 0 or buf_gds-sum.OutInt-Qnty          <> 0 or buf_gds-sum.OutInt-CostSum  <> 0 or buf_gds-sum.OutInt-SaleSum     <> 0 or
     buf_gds-sum.RetInt-Qnty        <> 0 or buf_gds-sum.RetInt-CostSum       <> 0 or buf_gds-sum.RetInt-SaleSum  <> 0 or buf_gds-sum.Inv-Qnty           <> 0 or
     buf_gds-sum.Inv-CostSum        <> 0 or buf_gds-sum.Inv-SaleSum          <> 0 or buf_gds-sum.Spi-Qnty        <> 0 or buf_gds-sum.Spi-CostSum        <> 0 or
     buf_gds-sum.Spi-SaleSum        <> 0 or buf_gds-sum.InProiz-Qnty         <> 0 or buf_gds-sum.InProiz-CostSum <> 0 or buf_gds-sum.InProiz-SaleSum    <> 0 or
     buf_gds-sum.OutProiz-Qnty      <> 0 or buf_gds-sum.OutProiz-CostSum     <> 0 or buf_gds-sum.OutProiz-SaleSum <> 0 or buf_gds-sum.Per-SaleSum       <> 0 or
     buf_gds-sum.Free-Qnty          <> 0 or buf_gds-sum.Res-Qnty             <> 0
  then do:
    run PutTitul in this-procedure .
    if p-num = 4 and SumsOnly then do:
      if var-client <> "" then do:
        run macr_excel_char (var-client, v-row, 1) .
        assign v-row = v-row + 1 .
        PUT stream OutStream "| " var-client format "X(60)" "|" at beg  SKIP .
        assign  var-client = "" .
      end.
    end.
/*      if p-num = 2 then run PutTitul in this-procedure .  /* вывод шапок */*/
/*      if p-num < 2 or ( p-num < 4 and var-client = "" ) or var-client1 = "" then run PutTitul in this-procedure .  /* вывод шапок */*/
      /* для экселя */
      assign v-col = 1 .
      run macr_excel_char (ItogStr, v-row, v-col) .
      if use-column[1]  = yes then assign v-col = v-col + 1 .
      if use-column[2]  = yes then assign v-col = v-col + 1 .
      if use-column[3]  = yes then assign v-col = v-col + 1 .
      if use-column[4]  = yes then assign v-col = v-col + 1 .
      if use-column[5]  = yes then assign v-col = v-col + 1 .
      if use-column[6]  = yes then assign v-col = v-col + 1 .
      if use-column[7]  = yes then assign v-col = v-col + 1 .
      if use-column[8]  = yes then assign v-col = v-col + 1 .
      if use-column[9]  = yes then assign v-col = v-col + 1 .

      if use-column[12] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[14] = yes then  do: run macr_excel_sum ( buf_gds-sum.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( buf_gds-sum.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[16] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum * 100 / buf_gds-sum.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum * 100 / buf_gds-sum.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[54] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[54] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[19] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum * 100 / buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-DiscntSum * 100 / buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-Qnty    - buf_gds-sum.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[57] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum , v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[57] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[22] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty      + buf_gds-sum.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum   + buf_gds-sum.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum   + buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum + buf_gds-sum.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-Qnty      + buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-CostSum   + buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-SaleSum   + buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum  ) * 100 / ( buf_gds-sum.RetOut-SaleSum + buf_gds-sum.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty + buf_gds-sum.OutExtKass-Qnty - buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[60] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[60] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[25] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[26] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[27] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[30] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[67] = yes then  do: run macr_excel_sum ( buf_gds-sum.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[13] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[10] = yes then do: run macr_excel_sum ( buf_gds-sum.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] = yes then do: run macr_excel_sum ( buf_gds-sum.Effect-Value * 100 / ( buf_gds-sum.OutExt-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOut-CostSum - buf_gds-sum.RetOutKass-CostSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1 then do:     run macr_excel_sum ( buf_gds-sum.Alt-RestEnd-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.

      if use-column[89] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[92] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-SaleSum - buf_gds-sum.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-DiscntSum * 100 / buf_gds-sum.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[97] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[98] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[99] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[100] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[101] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[102] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[103] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[104] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[105] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[106] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[107] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[108] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[109] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[110] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[111] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[112] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[113] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[114] = yes then  do:                                     assign v-col = v-col + 1 . end.


      assign v-row = v-row + 1 .

      assign
        ii = 1
        jj = 1
      .
      if use-column[1]  = yes then assign ii = ii + 1  jj = jj + 1 .
      if use-column[2]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[3]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[4]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[5]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[6]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[7]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[8]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[9]  = yes then assign ii = ii + 1  jj = jj + 1.

      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetPost-CostSum
          ii = ii + 1
        .
      end.

      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum * 100 / buf_gds-sum.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum * 100 / buf_gds-sum.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty - buf_gds-sum.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum*/
          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum  - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum )
          ii = ii + 1
        .
      end.

      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum * 100 / buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-DiscntSum * 100 / buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-Qnty    - buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum*/
          line-frm.sum = buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum )
          ii = ii + 1
        .
      end.

      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty      + buf_gds-sum.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum   + buf_gds-sum.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum   + buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum + buf_gds-sum.OutExtKass-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-Qnty      + buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-CostSum   + buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-SaleSum   + buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum  ) * 100 / ( buf_gds-sum.RetOut-SaleSum + buf_gds-sum.RetOutKass-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty + buf_gds-sum.OutExtKass-Qnty - buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum*/
          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum  )
          ii = ii + 1
        .
      end.

      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Per-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Effect-Value * 100 / ( buf_gds-sum.OutExt-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOut-CostSum - buf_gds-sum.RetOutKass-CostSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.

      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-SaleSum - buf_gds-sum.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-DiscntSum * 100 / buf_gds-sum.Res-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /*line-frm.sum = ?*/
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /*line-frm.sum = ?*/
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /*line-frm.sum = ?*/
          ii = ii + 1
        .
      end.
      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /*line-frm.sum = ?*/
          ii = ii + 1
        .
      end.
      if use-column[101] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[102] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[103] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[104] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[105] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[106] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[107] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[108] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[109] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[110] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[111] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[112] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[113] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[114] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.



      put stream outstream "| " ItogStr format "X(60)" .
      for each line-frm :
        if line-frm.num >= jj then do:
          if line-frm.frm  = "->>,>>>,>>9.99" and line-frm.sum > 99999999 then put stream outstream  "|" at line-frm.beg line-frm.sum format  "->>>>>>>>>9.99".
          else put stream outstream  "|" at line-frm.beg line-frm.sum format line-frm.frm .
        end.
      end.
      put stream outstream   "|"  skip Line format frmt skip.
    end.

/* $Workfile$   E n d */