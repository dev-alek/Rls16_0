/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

assign
  buf_gds-sum.StartWay-Qnty         = 0
  buf_gds-sum.StartWay-CostSum      = 0
  buf_gds-sum.StartWay-SaleSum      = 0
  buf_gds-sum.EndWay-Qnty           = 0
  buf_gds-sum.EndWay-CostSum        = 0
  buf_gds-sum.EndWay-SaleSum        = 0
  buf_gds-sum.Free-Qnty             = 0
  buf_gds-sum.Free-CostSum          = 0
  buf_gds-sum.Free-SaleSum          = 0
  buf_gds-sum.Res-Qnty              = 0
  buf_gds-sum.Res-CostSum           = 0
  buf_gds-sum.Res-SaleSum           = 0
  buf_gds-sum.Res-DiscntSum         = 0
  buf_gds-sum.InExt-Qnty            = 0
  buf_gds-sum.InExt-CostSum         = 0
  buf_gds-sum.RetPost-Qnty          = 0
  buf_gds-sum.RetPost-CostSum       = 0
  buf_gds-sum.OutExt-Qnty           = 0
  buf_gds-sum.OutExt-CostSum        = 0
  buf_gds-sum.OutExt-SaleSum        = 0
  buf_gds-sum.OutExt-DiscntSum      = 0
  buf_gds-sum.RetOut-Qnty           = 0
  buf_gds-sum.RetOut-CostSum        = 0
  buf_gds-sum.RetOut-SaleSum        = 0
  buf_gds-sum.RetOut-DiscntSum      = 0
  buf_gds-sum.OutExtKass-Qnty       = 0
  buf_gds-sum.OutExtKass-CostSum    = 0
  buf_gds-sum.OutExtKass-SaleSum    = 0
  buf_gds-sum.OutExtKass-DiscntSum  = 0
  buf_gds-sum.RetOutKass-Qnty       = 0
  buf_gds-sum.RetOutKass-CostSum    = 0
  buf_gds-sum.RetOutKass-SaleSum    = 0
  buf_gds-sum.RetOutKass-DiscntSum  = 0
  buf_gds-sum.InInt-Qnty            = 0
  buf_gds-sum.InInt-CostSum         = 0
  buf_gds-sum.InInt-SaleSum         = 0
  buf_gds-sum.OutInt-Qnty           = 0
  buf_gds-sum.OutInt-CostSum        = 0
  buf_gds-sum.OutInt-SaleSum        = 0
  buf_gds-sum.RetInt-Qnty           = 0
  buf_gds-sum.RetInt-CostSum        = 0
  buf_gds-sum.RetInt-SaleSum        = 0
  buf_gds-sum.Inv-Qnty              = 0
  buf_gds-sum.Inv-CostSum           = 0
  buf_gds-sum.Inv-SaleSum           = 0
  buf_gds-sum.Spi-Qnty              = 0
  buf_gds-sum.Spi-CostSum           = 0
  buf_gds-sum.Spi-SaleSum           = 0
  buf_gds-sum.InProiz-Qnty          = 0
  buf_gds-sum.InProiz-CostSum       = 0
  buf_gds-sum.InProiz-SaleSum       = 0
  buf_gds-sum.OutProiz-Qnty         = 0
  buf_gds-sum.OutProiz-CostSum      = 0
  buf_gds-sum.OutProiz-SaleSum      = 0
  buf_gds-sum.Per-SaleSum           = 0
  buf_gds-sum.Effect-Value          = 0
  buf_gds-sum.Alt-RestEnd-Qnty      = 0
.

/* $Workfile$   E n d */