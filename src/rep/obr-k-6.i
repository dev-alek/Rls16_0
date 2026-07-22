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
      /* для экселя */
      if sys-key = "parts" then do:
         run macr_cell_format ( 10 , yes, no, ?, v-row, 1, v-row, 100) .
      end.
      assign v-col = 1 .
      if use-column[1]  = yes then do: run macr_excel_char ( string (gds-prop.b-code), v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[2]  = yes then do: run macr_excel_char ( gds-prop.artic     , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[3]  = yes then do: run macr_excel_char ( gds-prop.gds-name  , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[4]  = yes then do: run macr_excel_char ( gds-prop.unit-base , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[5]  = yes then do: run macr_excel_sum  ( gds-prop.Cost-Price, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[6]  = yes then do:
        if prod-zen = yes then do:
          run macr_excel_sum  ( gds-prop.Avrg-Sale-Price, v-row, v-col, 2) .
        end.
        else do:
          run macr_excel_sum  ( gds-prop.Last-Sale-Price, v-row, v-col, 2) .
        end.
        assign v-col = v-col + 1 .
      end.
      if use-column[7]  = yes then do: run macr_excel_sum  ( gds-prop.Up-Plan, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[8]  = yes then do:
        if gds-prop.LastPer-Date <> ? then do: run macr_excel_char (string(gds-prop.LastPer-Date,"99.99.9999"), v-row, v-col) .  end.
        assign v-col = v-col + 1 .
      end.
      if use-column[9]  = yes then do: run macr_excel_char (gds-prop.LastPer-Num, v-row, v-col) . assign v-col = v-col + 1 . end.

      if use-column[12] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[14] = yes then  do: run macr_excel_sum ( gds-prop.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( gds-prop.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( gds-prop.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( gds-prop.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[16] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum * 100 / gds-prop.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum * 100 / gds-prop.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[54] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[54] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[19] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum * 100 / gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-DiscntSum * 100 / gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-Qnty    - gds-prop.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[57] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum , v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[57] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[22] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty      + gds-prop.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum   + gds-prop.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum   + gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-Qnty      + gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-CostSum   + gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-SaleSum   + gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum  ) * 100 / ( gds-prop.RetOut-SaleSum + gds-prop.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty + gds-prop.OutExtKass-Qnty - gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
/*      if use-column[60] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.*/
      if use-column[60] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[25] = yes then  do: run macr_excel_sum ( gds-prop.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( gds-prop.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( gds-prop.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[26] = yes then  do: run macr_excel_sum ( gds-prop.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( gds-prop.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( gds-prop.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[27] = yes then  do: run macr_excel_sum ( gds-prop.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( gds-prop.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( gds-prop.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[30] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[67] = yes then  do: run macr_excel_sum ( gds-prop.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[13] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[10] =  yes then  do: run macr_excel_sum ( gds-prop.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] =  yes then  do: run macr_excel_sum ( gds-prop.Up-Fact, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1  then  do: run macr_excel_sum ( gds-prop.Alt-RestEnd-Qnty, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[89] = yes then  do: run macr_excel_sum ( gds-prop.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( gds-prop.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( gds-prop.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[92] = yes then  do: run macr_excel_sum ( gds-prop.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( gds-prop.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( gds-prop.Res-SaleSum - gds-prop.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( gds-prop.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( gds-prop.Res-DiscntSum * 100 / gds-prop.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.

      if use-column[97]  = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[98]  = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[99]  = yes then  do:                                     assign v-col = v-col + 1 . end.
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
      if name-tov = 3 and use-column[3] = yes then do:
        assign   v-col = 1 .
        if use-column[1]  = yes then  assign v-col = v-col + 1 .
        if use-column[2]  = yes then  assign v-col = v-col + 1 .
        run macr_excel_char ( gds-prop.gds-name1, v-row, v-col) .
        assign
          v-row = v-row + 1
          .
      end.

      assign
        ii = 1
        jj = 1
      .

    if ExportZUM then do:
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
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.b-code format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.b-code format line-frm.frm {&tabulation}.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[2]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.artic format "X(16)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg gds-prop.artic format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[3]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.gds-name format "X(40)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg gds-prop.gds-name format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[4]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.unit-base format "X(4)" {&tabulation} .
        put stream outstream  "|" at line-frm.beg gds-prop.unit-base format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[5]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")   {&tabulation} .
        put stream outstream  "|" at line-frm.beg gds-prop.Cost-Price format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[6]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if prod-zen = yes then do:
           if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")   {&tabulation} .
           put stream outstream  "|" at line-frm.beg gds-prop.Avrg-Sale-Price format line-frm.frm .
        end.
        else do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  {&tabulation} .
          put stream outstream  "|" at line-frm.beg gds-prop.Last-Sale-Price format line-frm.frm .
        end.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[7]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.Up-Plan format line-frm.frm .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")  {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[8]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.LastPer-Date format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.LastPer-Date format "99/99/9999" {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[9]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.LastPer-Num format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.LastPer-Num format "X(10)" {&tabulation} .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.

      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetPost-CostSum
          ii = ii + 1
        .
      end.

      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum * 100 / gds-prop.OutExt-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum * 100 / gds-prop.RetOut-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty - gds-prop.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum*/
          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum * 100 / gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-DiscntSum * 100 / gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-Qnty    - gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum*/
          line-frm.sum = gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty      + gds-prop.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum   + gds-prop.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum   + gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-Qnty      + gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-CostSum   + gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-SaleSum   + gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum  ) * 100 / ( gds-prop.RetOut-SaleSum + gds-prop.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty + gds-prop.OutExtKass-Qnty - gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
/*          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum*/
          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - (gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum  )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.

      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Per-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Up-Fact
          ii = ii + 1
        .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.
      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-SaleSum - gds-prop.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-DiscntSum * 100 / gds-prop.Res-SaleSum
          ii = ii + 1
        .
      end.

      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /* line-frm.sum =  */
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /* line-frm.sum =  */
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /* line-frm.sum =  */
          ii = ii + 1
        .
      end.
      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          /* line-frm.sum =  */
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
        put stream outstream  "|" at line-frm.beg gds-prop.gds-name1 format line-frm.frm .
        assign  ii = ii + 1   .
        for each line-frm :
          if line-frm.num > ii  then  put stream outstream  "|" at line-frm.beg .
        end.
        put stream outstream   "|" at beg  skip .
      end.

/* $Workfile$   E n d */