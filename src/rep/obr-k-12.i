/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

печать партионной таблицы воборотке по партиям иценам производителя АПТЕКА

Автор: Чернова Светлана Александровна
Дата создания: 02/05/10
Author: Svetlana Chernova
Creation date: 02/05/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
      /* для экселя */

      assign v-col = 1 .
      if use-column[1]  = yes then do: run macr_excel_char ( string ( o_temp-parts.b-code ) , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[2]  = yes then do: run macr_excel_char ( o_temp-parts.part-code  , v-row, v-col) . assign v-col = v-col + 1 . end.
      /*if use-column[2]  = yes then do: run macr_excel_char ( o_temp-parts.part-code + "::" + o_temp-parts.in-code + "::" + o_temp-parts.artic + "::" + o_temp-parts.prod-type + "::" + string(o_temp-parts.prod-code) + "::" + string(o_temp-parts.obj-type)  + "::" + string(o_temp-parts.obj-code) , v-row, v-col) . assign v-col = v-col + 1 . end.*/
      if use-column[3]  = yes then do: run macr_excel_char ( o_temp-parts.gds-name, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[4]  = yes then do: run macr_excel_char ( o_temp-parts.unit-base, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[5]  = yes then do: run macr_excel_sum  ( o_temp-parts.Cost-Price, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[6]  = yes then do:
        if prod-zen = yes then do:
          run macr_excel_sum  ( o_temp-parts.Avrg-Sale-Price, v-row, v-col, 2) .
        end.
        else do:
          run macr_excel_sum  ( o_temp-parts.Last-Sale-Price, v-row, v-col, 2) .
        end.
        assign v-col = v-col + 1 .
      end.
      if use-column[7]  = yes then do: run macr_excel_sum  ( o_temp-parts.Up-Plan, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[8]  = yes then do:
        if o_temp-parts.LastPer-Date <> ? then do: run macr_excel_char (string(o_temp-parts.LastPer-Date,"99.99.9999"), v-row, v-col) .  end.
        assign v-col = v-col + 1 .
      end.
      if use-column[9]  = yes then do: run macr_excel_char (o_temp-parts.LastPer-Num, v-row, v-col) . assign v-col = v-col + 1 . end.

      if use-column[12] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[14] = yes then  do: run macr_excel_sum ( o_temp-parts.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( o_temp-parts.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( o_temp-parts.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( o_temp-parts.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[16] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum * 100 / o_temp-parts.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum * 100 / o_temp-parts.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[54] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[19] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum * 100 / o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-DiscntSum * 100 / o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-Qnty    - o_temp-parts.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[57] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[22] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty      + o_temp-parts.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum   + o_temp-parts.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum   + o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum + o_temp-parts.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-Qnty      + o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-CostSum   + o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-SaleSum   + o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum  ) * 100 / ( o_temp-parts.RetOut-SaleSum + o_temp-parts.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty + o_temp-parts.OutExtKass-Qnty - o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum + o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[60] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[25] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[26] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[27] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[30] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[67] = yes then  do: run macr_excel_sum ( o_temp-parts.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[13] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[10] =  yes then  do: run macr_excel_sum ( o_temp-parts.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] =  yes then  do: run macr_excel_sum ( o_temp-parts.Up-Fact, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1  then  do: run macr_excel_sum ( o_temp-parts.Alt-RestEnd-Qnty, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[89] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[92] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-SaleSum - o_temp-parts.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-DiscntSum * 100 / o_temp-parts.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[97]  = yes then  do: run macr_excel_sum ( o_temp-parts.price-prod            , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[98]  = yes then  do: run macr_excel_sum ( o_temp-parts.price-prodwithvat     , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[99]  = yes then  do: run macr_excel_sum ( o_temp-parts.prod-vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[100] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-vat-prc          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[101] = yes then  do: run macr_excel_sum ( o_temp-parts.price-supp            , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[102] = yes then  do: run macr_excel_sum ( o_temp-parts.price-suppvat         , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[103] = yes then  do: run macr_excel_sum ( o_temp-parts.suppvat               , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[104] = yes then  do: run macr_excel_sum ( o_temp-parts.suppvat-prc           , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[105] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-1                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[106] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-1-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[107] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-crsavat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[108] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-crsa             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[109] = yes then  do: run macr_excel_sum ( o_temp-parts.vat-crsa              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[110] = yes then  do: run macr_excel_sum ( o_temp-parts.vat-crsa-prc          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[111] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[112] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[113] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[114] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[115] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[116] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2-prcvat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[117] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[118] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3-prcvat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.


      assign v-row = v-row + 1 .
      if name-tov = 3 and use-column[3]  = yes then do:
        assign   v-col = 1 .
        if use-column[1]  = yes then  assign v-col = v-col + 1 .
        if use-column[2]  = yes then  assign v-col = v-col + 1 .
        run macr_excel_char (o_temp-parts.gds-name1, v-row, v-col) .
        assign v-row = v-row + 1 .
      end.

      assign
        ii = 1
        jj = 1
      .

    if ExportZUM then do:
      if tog-obj = true then do: /* раздельно по объектам */
        put stream txt-file
          o_temp-parts.obj-type format "X(5)"   {&tabulation}
          o_temp-parts.obj-code format ">>>>>>>9" {&tabulation}
          o_temp-parts.obj-name format "X(50)"   {&tabulation}
        .
      end.
      put stream txt-file
        o_temp-parts.grp-name format "X(70)"  {&tabulation}
        o_temp-parts.prod-type format "X(5)"   {&tabulation}
        o_temp-parts.prod-code format ">>>>>>>>>>>9" {&tabulation}
        o_temp-parts.prod-name format "X(50)"  {&tabulation}
      .
    end.

      if use-column[1]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.b-code format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.b-code format line-frm.frm {&tabulation}.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[2]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.part-code format "X(16)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg o_temp-parts.part-code format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[3]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.gds-name format "X(40)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg o_temp-parts.gds-name format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[4]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.unit-base format "X(4)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg o_temp-parts.unit-base format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[5]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Cost-Price,frm-sum1),".",",")   {&tabulation} .
        put stream outstream  "|" at line-frm.beg o_temp-parts.Cost-Price format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[6]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if prod-zen = yes then do:
           if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Avrg-Sale-Price,frm-sum1),".",",")   {&tabulation} .
           put stream outstream  "|" at line-frm.beg o_temp-parts.Avrg-Sale-Price format line-frm.frm .
        end.
        else do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Last-Sale-Price,frm-sum1),".",",")  {&tabulation} .
          put stream outstream  "|" at line-frm.beg o_temp-parts.Last-Sale-Price format line-frm.frm .
        end.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[7]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.Up-Plan format line-frm.frm .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Up-Plan,frm-sum1),".",",")  {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[8]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.LastPer-Date format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.LastPer-Date format "99/99/9999" {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[9]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.LastPer-Num format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.LastPer-Num format "X(10)" {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.

      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetPost-CostSum
          ii = ii + 1
        .
      end.

      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum * 100 / o_temp-parts.OutExt-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum * 100 / o_temp-parts.RetOut-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty - o_temp-parts.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum * 100 / o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-DiscntSum * 100 / o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-Qnty    - o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty      + o_temp-parts.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum   + o_temp-parts.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum   + o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum + o_temp-parts.OutExtKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-Qnty      + o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-CostSum   + o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-SaleSum   + o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum  ) * 100 / ( o_temp-parts.RetOut-SaleSum + o_temp-parts.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty + o_temp-parts.OutExtKass-Qnty - o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum + o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - (o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum  )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Per-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Up-Fact
          ii = ii + 1
        .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.
      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-SaleSum - o_temp-parts.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-DiscntSum * 100 / o_temp-parts.Res-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.price-prod
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.price-prodwithvat
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.prod-vat
          ii = ii + 1
        .
      end.

      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.prod-vat-prc
          ii = ii + 1
        .
     end.

if use-column[101] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.price-supp     ii = ii + 1 . end.
if use-column[102] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.price-suppvat  ii = ii + 1 . end.
if use-column[103] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.suppvat        ii = ii + 1 . end.
if use-column[104] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.suppvat-prc    ii = ii + 1 . end.
if use-column[105] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-1          ii = ii + 1 . end.
if use-column[106] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-1-prc      ii = ii + 1 . end.
if use-column[107] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.prod-crsavat   ii = ii + 1 . end.
if use-column[108] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.prod-crsa      ii = ii + 1 . end.
if use-column[109] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.vat-crsa       ii = ii + 1 . end.
if use-column[110] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.vat-crsa-prc   ii = ii + 1 . end.
if use-column[111] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2          ii = ii + 1 . end.
if use-column[112] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2-prc      ii = ii + 1 . end.
if use-column[113] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3          ii = ii + 1 . end.
if use-column[114] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3-prc      ii = ii + 1 . end.
if use-column[115] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2vat       ii = ii + 1 . end.
if use-column[116] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2-prcvat   ii = ii + 1 . end.
if use-column[117] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3vat       ii = ii + 1 . end.
if use-column[118] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3-prcvat   ii = ii + 1 . end.


      for each line-frm :
        if line-frm.num >= jj  then do:
          put stream outstream  "|" at line-frm.beg line-frm.sum format line-frm.frm .
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(line-frm.sum,frm-qnty1),".",",")  {&tabulation} .
        end.
      end.
      put stream outstream   "|"  skip .
      if ExportZUM then put stream txt-file  {&new-line} .

      if name-tov = 3 and use-column[3]  = yes then do:
        assign ii = 1  .
        if use-column[1]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        if use-column[2]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.gds-name1 format line-frm.frm .
        assign  ii = ii + 1   .
        for each line-frm :
          if line-frm.num > ii  then  put stream outstream  "|" at line-frm.beg .
        end.
        put stream outstream   "|" at beg  skip .
      end.

/* $Workfile$ e n d */