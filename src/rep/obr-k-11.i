/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание временной таблицы партий для Оборотки с ценами производител

Автор: Чернова Светлана Александровна
Дата создания: 02/05/10
Author: Svetlana Chernova
Creation date: 02/05/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*
gds-prop.obj-type
gds-prop.obj-code
gds-prop.prod-type
gds-prop.prod-code
gds-prop.artic
v-fact-order-end
v-fact-order-start
*/

/* Остаток по партиям на конец */
define buffer cli_clients for ub.clients  .
define buffer buf_price-doc for ub.price-doc  .

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .

for each temp-parts : delete temp-parts . end.
run partslib-init-temp-parts-by-factord (
      input gds-prop.obj-type
  ,   input gds-prop.obj-code
  ,   input gds-prop.artic
  ,   input gds-prop.prod-type
  ,   input gds-prop.prod-code
  ,   input v-fact-order-start
  ,   input false ) .

  for each temp-parts :
     find first o_temp-parts  where
                o_temp-parts.artic     = temp-parts.artic      and
                o_temp-parts.prod-type = temp-parts.prod-type  and
                o_temp-parts.prod-code = temp-parts.prod-code  and
                o_temp-parts.obj-type  = temp-parts.obj-type   and
                o_temp-parts.obj-code  = temp-parts.obj-code   and
                o_temp-parts.in-code   = temp-parts.in-code    and
                o_temp-parts.part-code = temp-parts.part-code  no-error .

      if not available o_temp-parts then do:
         create o_temp-parts.
         buffer-copy temp-parts to o_temp-parts
         assign
         o_temp-parts.StartWay-Qnty = temp-parts.fact-qnty
         .
          find first ub.parts no-lock where
                ub.parts.artic     = temp-parts.artic      and
                ub.parts.prod-type = temp-parts.prod-type  and
                ub.parts.prod-code = temp-parts.prod-code  and
                ub.parts.obj-type  = temp-parts.obj-type   and
                ub.parts.obj-code  = temp-parts.obj-code   and
                ub.parts.in-code   = temp-parts.in-code    and
                ub.parts.part-code = temp-parts.part-code  no-error .
          if available ub.parts then do:
            { rep/obr-k-13.i ub.parts }
          end.
       end.
       else do:
         assign
         o_temp-parts.StartWay-Qnty = temp-parts.fact-qnty
         .
       end.

  end.

  for each temp-parts : delete temp-parts . end.

/* Остаток по партиям на конец */
run partslib-init-temp-parts-by-factord (
      input gds-prop.obj-type
  ,   input gds-prop.obj-code
  ,   input gds-prop.artic
  ,   input gds-prop.prod-type
  ,   input gds-prop.prod-code
  ,   input v-fact-order-end
  ,   input false ).

  for each temp-parts :
     find first o_temp-parts  where
                o_temp-parts.artic     = temp-parts.artic      and
                o_temp-parts.prod-type = temp-parts.prod-type  and
                o_temp-parts.prod-code = temp-parts.prod-code  and
                o_temp-parts.obj-type  = temp-parts.obj-type   and
                o_temp-parts.obj-code  = temp-parts.obj-code   and
                o_temp-parts.in-code   = temp-parts.in-code    and
                o_temp-parts.part-code = temp-parts.part-code  no-error .

      if not available o_temp-parts then do:
        create o_temp-parts.
        buffer-copy temp-parts to o_temp-parts
        assign
         o_temp-parts.EndWay-Qnty = temp-parts.fact-qnty
         .
          find first ub.parts no-lock where
                ub.parts.artic     = temp-parts.artic      and
                ub.parts.prod-type = temp-parts.prod-type  and
                ub.parts.prod-code = temp-parts.prod-code  and
                ub.parts.obj-type  = temp-parts.obj-type   and
                ub.parts.obj-code  = temp-parts.obj-code   and
                ub.parts.in-code   = temp-parts.in-code    and
                ub.parts.part-code = temp-parts.part-code  no-error .
          if available ub.parts then do:
            { rep/obr-k-13.i ub.parts }
          end.
      end.
      else do:
        assign
          o_temp-parts.EndWay-Qnty = temp-parts.fact-qnty
      .
      end.
  end.


  for each ub.doc-line no-lock where
           ub.doc-line.obj-type  = gds-prop.obj-type  and
           ub.doc-line.obj-code  = gds-prop.obj-code  and
           ub.doc-line.artic     = gds-prop.artic     and
           ub.doc-line.prod-type = gds-prop.prod-type and
           ub.doc-line.prod-code = gds-prop.prod-code and
           ub.doc-line.status_   = {&fact} and
           ub.doc-line.fact-order >= v-fact-order-start and
           ub.doc-line.fact-order <= v-fact-order-end  ,
      first ub.trn-doc no-lock where
            ub.trn-doc.doc-code = ub.doc-line.doc-code and
            ub.trn-doc.status_  = {&fact}  :
     for each ub.parts no-lock where
              ub.parts.out-code  = ub.doc-line.doc-code   and
              ub.parts.obj-type  = ub.doc-line.obj-type   and
              ub.parts.obj-code  = ub.doc-line.obj-code   and
              ub.parts.artic     = ub.doc-line.artic      and
              ub.parts.prod-type = ub.doc-line.prod-type  and
              ub.parts.prod-code = ub.doc-line.prod-code  :


     find first o_temp-parts  where
                o_temp-parts.artic     = ub.parts.artic      and
                o_temp-parts.prod-type = ub.parts.prod-type  and
                o_temp-parts.prod-code = ub.parts.prod-code  and
                o_temp-parts.obj-type  = ub.parts.obj-type   and
                o_temp-parts.obj-code  = ub.parts.obj-code   and
                o_temp-parts.in-code   = ub.parts.in-code    and
                o_temp-parts.part-code = ub.parts.part-code  no-error .


     if not available o_temp-parts then do:
        create o_temp-parts.
        buffer-copy ub.parts to o_temp-parts.
        { rep/obr-k-13.i ub.parts }
     end.
      case ub.doc-line.ext-doc-type :
      when {&TDEDT_Pri_Vnesh}           then do:
         assign
           o_temp-parts.InExt-Qnty = o_temp-parts.InExt-Qnty + ub.parts.fact-qnty
           o_temp-parts.rPri_Vnesh = o_temp-parts.rPri_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bPri_Vnesh = o_temp-parts.bPri_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.InExt-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rPri_Vnesh else o_temp-parts.bPri_Vnesh
           /*o_temp-parts.InExt-SaleSum = o_temp-parts.InExt-Qnty * o_temp-parts.Last-Sale-Price*/
         .
      end.
      when {&TDEDT_Ras_Vnesh}           then do:
         assign
           o_temp-parts.OutExt-Qnty  = o_temp-parts.OutExt-Qnty  + ub.parts.fact-qnty
           o_temp-parts.rRas_Vnesh = o_temp-parts.rRas_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bRas_Vnesh = o_temp-parts.bRas_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.OutExt-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rRas_Vnesh else o_temp-parts.bRas_Vnesh
           o_temp-parts.OutExt-SaleSum = o_temp-parts.OutExt-Qnty * o_temp-parts.Last-Sale-Price
          .
      end.
      when {&TDEDT_Ras_Vnesh_VP}        then do:
         assign
           o_temp-parts.RetPost-Qnty  = o_temp-parts.RetPost-Qnty  + ub.parts.fact-qnty
           o_temp-parts.rRas_Vnesh_VP = o_temp-parts.rRas_Vnesh_VP + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bRas_Vnesh_VP = o_temp-parts.bRas_Vnesh_VP + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.RetPost-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rRas_Vnesh_VP else o_temp-parts.bRas_Vnesh_VP
           /*o_temp-parts.RetPost-SaleSum = o_temp-parts.RetPost-Qnty * o_temp-parts.Last-Sale-Price*/
          .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}      then do:
         assign
           o_temp-parts.OutExtKass-Qnty  = o_temp-parts.OutExtKass-Qnty  + ub.parts.fact-qnty
           o_temp-parts.rRas_Vnesh_Kass = o_temp-parts.rRas_Vnesh_Kass + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bRas_Vnesh_Kass = o_temp-parts.bRas_Vnesh_Kass + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.OutExtKass-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rRas_Vnesh_Kass else o_temp-parts.bRas_Vnesh_Kass
           o_temp-parts.OutExtKass-SaleSum = o_temp-parts.OutExtKass-Qnty * o_temp-parts.Last-Sale-Price
          .
      end.
      when {&TDEDT_Vozvrat_Vnesh}       then do:
         assign
           o_temp-parts.RetOut-Qnty    = o_temp-parts.RetOut-Qnty    + ub.parts.fact-qnty
           o_temp-parts.rVozvrat_Vnesh = o_temp-parts.rVozvrat_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bVozvrat_Vnesh = o_temp-parts.bVozvrat_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.RetOut-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rVozvrat_Vnesh else o_temp-parts.bVozvrat_Vnesh
           o_temp-parts.RetOut-SaleSum = o_temp-parts.RetOut-Qnty * o_temp-parts.Last-Sale-Price
          .

      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}  then do:
         assign
           o_temp-parts.RetOutKass-Qnty     = o_temp-parts.RetOutKass-Qnty  + ub.parts.fact-qnty
           o_temp-parts.rVozvrat_Vnesh_Kass = o_temp-parts.rVozvrat_Vnesh_Kass + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bVozvrat_Vnesh_Kass = o_temp-parts.bVozvrat_Vnesh_Kass + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.RetOutKass-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rVozvrat_Vnesh_Kass else o_temp-parts.bVozvrat_Vnesh_Kass
           o_temp-parts.RetOutKass-SaleSum = o_temp-parts.RetOutKass-Qnty * o_temp-parts.Last-Sale-Price
          .
      end.
      when {&TDEDT_Spi_Vnesh}           then do:
         assign
           o_temp-parts.Spi-Qnty   = o_temp-parts.Spi-Qnty   + ub.parts.fact-qnty
           o_temp-parts.rSpi_Vnesh = o_temp-parts.rSpi_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bSpi_Vnesh = o_temp-parts.bSpi_Vnesh + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.Spi-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rSpi_Vnesh else o_temp-parts.bSpi_Vnesh
           o_temp-parts.Spi-SaleSum = o_temp-parts.Spi-Qnty * o_temp-parts.Last-Sale-Price
          .
      end.

      when {&TDEDT_Pri_Perem}           then do:
         assign
           o_temp-parts.InInt-Qnty = o_temp-parts.InInt-Qnty + ub.parts.fact-qnty
           o_temp-parts.rPri_Perem = o_temp-parts.rPri_Perem + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bPri_Perem = o_temp-parts.bPri_Perem + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.InInt-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rPri_Perem else o_temp-parts.bPri_Perem
           o_temp-parts.InInt-SaleSum = o_temp-parts.InInt-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      when {&TDEDT_Ras_Perem }          then do:
         assign
           o_temp-parts.OutInt-Qnty  = o_temp-parts.OutInt-Qnty + ub.parts.fact-qnty
           o_temp-parts.rRas_Perem = o_temp-parts.rRas_Perem + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bRas_Perem = o_temp-parts.bRas_Perem + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.OutInt-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rRas_Perem else o_temp-parts.bRas_Perem
           o_temp-parts.OutInt-SaleSum = o_temp-parts.OutInt-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      when {&TDEDT_Vozvrat_Perem}       then do:
         assign
           o_temp-parts.RetInt-Qnty    = o_temp-parts.RetInt-Qnty    + ub.parts.fact-qnty
           o_temp-parts.rVozvrat_Perem = o_temp-parts.rVozvrat_Perem + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bVozvrat_Perem = o_temp-parts.bVozvrat_Perem + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.RetInt-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rVozvrat_Perem else o_temp-parts.bVozvrat_Perem
           o_temp-parts.RetInt-SaleSum = o_temp-parts.RetInt-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      when {&TDEDT_Ras_Prvo}            or
      when {&TDEDT_Spi_Prvo}            then do:
         assign
           o_temp-parts.OutProiz-Qnty  = o_temp-parts.OutProiz-Qnty  +   ub.parts.fact-qnty
           o_temp-parts.rRas_Prvo = o_temp-parts.rRas_Prvo + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bRas_Prvo = o_temp-parts.bRas_Prvo + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.OutProiz-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rRas_Prvo else o_temp-parts.bRas_Prvo
           o_temp-parts.OutProiz-SaleSum = o_temp-parts.OutProiz-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      when {&TDEDT_Pri_Prvo}            then do:
         assign
           o_temp-parts.InProiz-Qnty    = o_temp-parts.InProiz-Qnty  +   ub.parts.fact-qnty
           o_temp-parts.rPri_Prvo       = o_temp-parts.rPri_Prvo     + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bPri_Prvo       = o_temp-parts.bPri_Prvo     + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.InProiz-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rPri_Prvo else o_temp-parts.bPri_Prvo
           o_temp-parts.InProiz-SaleSum = o_temp-parts.InProiz-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      when {&TDEDT_Inv}                 or
      when {&TDEDT_Corr_Acc_Price}      or
      when {&TDEDT_Corr_Minus_Parts}    or
      when {&TDEDT_Peresort}            or
      when {&TDEDT_Chg_Purch_Code}      then do:
         assign
           o_temp-parts.Inv-Qnty    = o_temp-parts.Inv-Qnty  +   ub.parts.fact-qnty
           o_temp-parts.rInv        = o_temp-parts.rInv + ( ub.parts.fact-qnty * ub.parts.price-rubl )
           o_temp-parts.bInv        = o_temp-parts.bInv + ( ub.parts.fact-qnty * ub.parts.price-base )
           o_temp-parts.Inv-CostSum = if x-SET_val_TYPE = 1 then o_temp-parts.rInv else o_temp-parts.bInv
           o_temp-parts.Inv-SaleSum = o_temp-parts.Inv-Qnty * o_temp-parts.Last-Sale-Price
         .
      end.
      end case.
  end.
  end.

/* $Workfile$ e n d */