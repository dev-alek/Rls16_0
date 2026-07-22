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
  buf_gds-sum.StartWay-Qnty         = buf_gds-sum.StartWay-Qnty          +  gds-prop.StartWay-Qnty
  buf_gds-sum.StartWay-CostSum      = buf_gds-sum.StartWay-CostSum       +  gds-prop.StartWay-CostSum
  buf_gds-sum.StartWay-SaleSum      = buf_gds-sum.StartWay-SaleSum       +  gds-prop.StartWay-SaleSum
  buf_gds-sum.EndWay-Qnty           = buf_gds-sum.EndWay-Qnty            +  gds-prop.EndWay-Qnty
  buf_gds-sum.EndWay-CostSum        = buf_gds-sum.EndWay-CostSum         +  gds-prop.EndWay-CostSum
  buf_gds-sum.EndWay-SaleSum        = buf_gds-sum.EndWay-SaleSum         +  gds-prop.EndWay-SaleSum
  buf_gds-sum.InExt-Qnty            = buf_gds-sum.InExt-Qnty             +  gds-prop.InExt-Qnty
  buf_gds-sum.InExt-CostSum         = buf_gds-sum.InExt-CostSum          +  gds-prop.InExt-CostSum
  buf_gds-sum.RetPost-Qnty          = buf_gds-sum.RetPost-Qnty           +  gds-prop.RetPost-Qnty
  buf_gds-sum.RetPost-CostSum       = buf_gds-sum.RetPost-CostSum        +  gds-prop.RetPost-CostSum
  buf_gds-sum.OutExt-Qnty           = buf_gds-sum.OutExt-Qnty            +  gds-prop.OutExt-Qnty
  buf_gds-sum.OutExt-CostSum        = buf_gds-sum.OutExt-CostSum         +  gds-prop.OutExt-CostSum
  buf_gds-sum.OutExt-SaleSum        = buf_gds-sum.OutExt-SaleSum         +  gds-prop.OutExt-SaleSum
  buf_gds-sum.OutExt-DiscntSum      = buf_gds-sum.OutExt-DiscntSum       +  gds-prop.OutExt-DiscntSum
  buf_gds-sum.RetOut-Qnty           = buf_gds-sum.RetOut-Qnty            +  gds-prop.RetOut-Qnty
  buf_gds-sum.RetOut-CostSum        = buf_gds-sum.RetOut-CostSum         +  gds-prop.RetOut-CostSum
  buf_gds-sum.RetOut-SaleSum        = buf_gds-sum.RetOut-SaleSum         +  gds-prop.RetOut-SaleSum
  buf_gds-sum.RetOut-DiscntSum      = buf_gds-sum.RetOut-DiscntSum       +  gds-prop.RetOut-DiscntSum
  buf_gds-sum.OutExtKass-Qnty       = buf_gds-sum.OutExtKass-Qnty        +  gds-prop.OutExtKass-Qnty
  buf_gds-sum.OutExtKass-CostSum    = buf_gds-sum.OutExtKass-CostSum     +  gds-prop.OutExtKass-CostSum
  buf_gds-sum.OutExtKass-SaleSum    = buf_gds-sum.OutExtKass-SaleSum     +  gds-prop.OutExtKass-SaleSum
  buf_gds-sum.OutExtKass-DiscntSum  = buf_gds-sum.OutExtKass-DiscntSum   +  gds-prop.OutExtKass-DiscntSum
  buf_gds-sum.RetOutKass-Qnty       = buf_gds-sum.RetOutKass-Qnty        +  gds-prop.RetOutKass-Qnty
  buf_gds-sum.RetOutKass-CostSum    = buf_gds-sum.RetOutKass-CostSum     +  gds-prop.RetOutKass-CostSum
.
assign
  buf_gds-sum.RetOutKass-SaleSum    = buf_gds-sum.RetOutKass-SaleSum     +  gds-prop.RetOutKass-SaleSum
  buf_gds-sum.RetOutKass-DiscntSum  = buf_gds-sum.RetOutKass-DiscntSum   +  gds-prop.RetOutKass-DiscntSum
  buf_gds-sum.InInt-Qnty            = buf_gds-sum.InInt-Qnty             +  gds-prop.InInt-Qnty
  buf_gds-sum.InInt-CostSum         = buf_gds-sum.InInt-CostSum          +  gds-prop.InInt-CostSum
  buf_gds-sum.InInt-SaleSum         = buf_gds-sum.InInt-SaleSum          +  gds-prop.InInt-SaleSum
  buf_gds-sum.OutInt-Qnty           = buf_gds-sum.OutInt-Qnty            +  gds-prop.OutInt-Qnty
  buf_gds-sum.OutInt-CostSum        = buf_gds-sum.OutInt-CostSum         +  gds-prop.OutInt-CostSum
  buf_gds-sum.OutInt-SaleSum        = buf_gds-sum.OutInt-SaleSum         +  gds-prop.OutInt-SaleSum
  buf_gds-sum.RetInt-Qnty           = buf_gds-sum.RetInt-Qnty            +  gds-prop.RetInt-Qnty
  buf_gds-sum.RetInt-CostSum        = buf_gds-sum.RetInt-CostSum         +  gds-prop.RetInt-CostSum
  buf_gds-sum.RetInt-SaleSum        = buf_gds-sum.RetInt-SaleSum         +  gds-prop.RetInt-SaleSum
  buf_gds-sum.Inv-Qnty              = buf_gds-sum.Inv-Qnty               +  gds-prop.Inv-Qnty
  buf_gds-sum.Inv-CostSum           = buf_gds-sum.Inv-CostSum            +  gds-prop.Inv-CostSum
  buf_gds-sum.Inv-SaleSum           = buf_gds-sum.Inv-SaleSum            +  gds-prop.Inv-SaleSum
  buf_gds-sum.Spi-Qnty              = buf_gds-sum.Spi-Qnty               +  gds-prop.Spi-Qnty
  buf_gds-sum.Spi-CostSum           = buf_gds-sum.Spi-CostSum            +  gds-prop.Spi-CostSum
  buf_gds-sum.Spi-SaleSum           = buf_gds-sum.Spi-SaleSum            +  gds-prop.Spi-SaleSum
  buf_gds-sum.InProiz-Qnty          = buf_gds-sum.InProiz-Qnty           +  gds-prop.InProiz-Qnty
  buf_gds-sum.InProiz-CostSum       = buf_gds-sum.InProiz-CostSum        +  gds-prop.InProiz-CostSum
  buf_gds-sum.InProiz-SaleSum       = buf_gds-sum.InProiz-SaleSum        +  gds-prop.InProiz-SaleSum
  buf_gds-sum.OutProiz-Qnty         = buf_gds-sum.OutProiz-Qnty          +  gds-prop.OutProiz-Qnty
  buf_gds-sum.OutProiz-CostSum      = buf_gds-sum.OutProiz-CostSum       +  gds-prop.OutProiz-CostSum
  buf_gds-sum.OutProiz-SaleSum      = buf_gds-sum.OutProiz-SaleSum       +  gds-prop.OutProiz-SaleSum
  buf_gds-sum.Per-SaleSum           = buf_gds-sum.Per-SaleSum            +  gds-prop.Per-SaleSum
  buf_gds-sum.Alt-RestEnd-Qnty      = buf_gds-sum.Alt-RestEnd-Qnty       +  gds-prop.Alt-RestEnd-Qnty
  buf_gds-sum.Effect-Value          = buf_gds-sum.Effect-Value           +  gds-prop.Effect-Value
  buf_gds-sum.Free-Qnty             = buf_gds-sum.Free-Qnty              +  gds-prop.Free-Qnty
  buf_gds-sum.Free-CostSum          = buf_gds-sum.Free-CostSum           +  gds-prop.Free-CostSum
  buf_gds-sum.Free-SaleSum          = buf_gds-sum.Free-SaleSum           +  gds-prop.Free-SaleSum
  buf_gds-sum.Res-Qnty              = buf_gds-sum.Res-Qnty               +  gds-prop.Res-Qnty
  buf_gds-sum.Res-CostSum           = buf_gds-sum.Res-CostSum            +  gds-prop.Res-CostSum
  buf_gds-sum.Res-DocSum            = buf_gds-sum.Res-DocSum             +  gds-prop.Res-DocSum
  buf_gds-sum.Res-SaleSum           = buf_gds-sum.Res-SaleSum            +  gds-prop.Res-SaleSum
  buf_gds-sum.Res-DiscntSum         = buf_gds-sum.Res-DiscntSum          +  gds-prop.Res-DiscntSum
.

/* $Workfile$   E n d */