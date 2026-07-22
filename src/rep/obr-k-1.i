/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

  if sys-key = "parts" then do:
     if buf_gds-obj.cash-parts = false then next.
  end.

  if not ShowZero-2 and not ShowZero then 
  if buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 and buf_gds-obj.last-doc < x-date-start then next .
  if ShowZero-2 and not ShowZero then if buf_gds-obj.fact-qnty = 0 and buf_gds-obj.last-doc < x-date-start then next .
  
  case RADIO-Nomenkl :
    when 2 then /* Текуща  */
      if buf_gds-obj.stts <> 0 then next .
    when 3 then /* "Удаленная" */
      if buf_gds-obj.stts = 0  then next .
  end case.

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  if tog-obj = true then do: /* раздельно по объектам */
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .
    assign
      gds-prop.StartWay-Qnty         = 0
      gds-prop.StartWay-CostSum      = 0
      gds-prop.StartWay-SaleSum      = 0
      gds-prop.EndWay-Qnty           = 0
      gds-prop.EndWay-CostSum        = 0
      gds-prop.EndWay-SaleSum        = 0
      gds-prop.InExt-Qnty            = 0
      gds-prop.InExt-CostSum         = 0
      gds-prop.RetPost-Qnty          = 0
      gds-prop.RetPost-CostSum       = 0
      gds-prop.OutExt-Qnty           = 0
      gds-prop.OutExt-CostSum        = 0
      gds-prop.OutExt-SaleSum        = 0
      gds-prop.OutExt-DiscntSum      = 0
      gds-prop.RetOut-Qnty           = 0
      gds-prop.RetOut-CostSum        = 0
      gds-prop.RetOut-SaleSum        = 0
      gds-prop.RetOut-DiscntSum      = 0
      gds-prop.OutExtKass-Qnty       = 0
      gds-prop.OutExtKass-CostSum    = 0
      gds-prop.OutExtKass-SaleSum    = 0
      gds-prop.OutExtKass-DiscntSum  = 0
      gds-prop.RetOutKass-Qnty       = 0
      gds-prop.RetOutKass-CostSum    = 0
      gds-prop.RetOutKass-SaleSum    = 0
      gds-prop.RetOutKass-DiscntSum  = 0
      gds-prop.InInt-Qnty            = 0
      gds-prop.InInt-CostSum         = 0
      gds-prop.InInt-SaleSum         = 0
      gds-prop.OutInt-Qnty           = 0
      gds-prop.OutInt-CostSum        = 0
      gds-prop.OutInt-SaleSum        = 0
      gds-prop.RetInt-Qnty           = 0
      gds-prop.RetInt-CostSum        = 0
      gds-prop.RetInt-SaleSum        = 0
      gds-prop.Inv-Qnty              = 0
      gds-prop.Inv-CostSum           = 0
      gds-prop.Inv-SaleSum           = 0
      gds-prop.Spi-Qnty              = 0
      gds-prop.Spi-CostSum           = 0
      gds-prop.Spi-SaleSum           = 0
      gds-prop.InProiz-Qnty          = 0
      gds-prop.InProiz-CostSum       = 0
      gds-prop.InProiz-SaleSum       = 0
      gds-prop.OutProiz-Qnty         = 0
      gds-prop.OutProiz-CostSum      = 0
      gds-prop.OutProiz-SaleSum      = 0
      gds-prop.Per-SaleSum           = 0
    .

    { gbl/gdsbcode.i  buf_gds-obj.gds-code  ?  gds-prop.b-code  no-error }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic
      view-as alert-box error .
    end.

    if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do: /* дата и номер последней переоценки за пириод */
      find last ub.price-list no-lock
        where ub.price-list.obj-type  = buf_gds-obj.obj-type
          and ub.price-list.obj-code  = buf_gds-obj.obj-code
          and ub.price-list.b-code    = gds-prop.b-code
          and ub.price-list.price-type = ""
          and ub.price-list.fact-order < v-fact-order-end
        use-index fact-close no-error .

      if available ub.price-list then do:
        find first ub.price-doc no-lock
          where ub.price-doc.doc-num  = ub.price-list.doc-num
        .
        assign
          gds-prop.Last-Sale-Price = ub.price-list.price-sale
          gds-prop.LastPer-Date    = ub.price-doc.doc-date
          gds-prop.LastPer-Num     = ub.price-doc.doc-num
        .
      end .
    end.

    { gbl/pftxvalg.i buf_gds-obj.gds-code {&vat-tax-code} ? g#host-code buf_gds-obj.obj-type buf_gds-obj.obj-code gds-prop.vat-pc no-error }

    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.obj-type  = buf2_clients.obj-type
       gds-prop.obj-code  = buf2_clients.obj-code
       gds-prop.obj-name  = buf2_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.gds-name1 = buf_goods.engl-name.
    .
/*  if g#gds-engl then assign gds-prop.gds-name = buf_goods.engl-name.*/
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.

    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .

    if sys-key = "parts" then do:
       { rep/obr-k-11.i }  /* создадим временную таблицу по партиям */
    end.
  end.

  { rep/obr-k-2.i } /* считаем остатки на начало и конец периода */

  { rep/obr-k-3.i }  /* считаем оборот за период */

/* $Workfile$   E n d */