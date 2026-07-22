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

define variable v1-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v1-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v1-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v1-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v1-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v1-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v1-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v1-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v1-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v1-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v1-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v1-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v1-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v1-other-base        like ub.ot-line.other-base      no-undo .
define variable v1-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v1-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v1-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable v2-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v2-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v2-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v2-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v2-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v2-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v2-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v2-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v2-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v2-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v2-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v2-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v2-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v2-other-base        like ub.ot-line.other-base      no-undo .
define variable v2-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v2-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v2-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable v-prt-b-code like ub.bar-code.b-code no-undo .
define buffer buf_gds-dtl for gds-dtl.
  /* обороты */
  for each buf_doc-line no-lock
    where buf_doc-line.obj-type   = buf_gds-obj.obj-type
      and buf_doc-line.obj-code   = buf_gds-obj.obj-code
      and buf_doc-line.prod-type  = buf_gds-obj.prod-type
      and buf_doc-line.prod-code  = buf_gds-obj.prod-code
      and buf_doc-line.artic      = buf_gds-obj.artic
      and buf_doc-line.status_    = {&fact}
      and buf_doc-line.fact-order >= v-fact-order-start
      and buf_doc-line.fact-order <  v-fact-order-end
    :
    run r-cost in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic , input buf_doc-line.prod-type
                                 , input buf_doc-line.prod-code  , output v1-fact-qnty        , output v1-vat-pc
                                 , output v1-slt-pc              , output v1-sum-base         , output v1-sum-rubl
                                 , output v1-vat-base            , output v1-vat-rubl         , output v1-slt-base
                                 , output v1-slt-rubl            , output v1-road-tax-base    , output v1-road-tax-rubl
                                 , output v1-transport-base      , output v1-transport-rubl   , output v1-other-base
                                 , output v1-other-rubl          , output v1-excise-base      , output v1-excise-rubl ).

    run r-sale in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic   , input buf_doc-line.prod-type
                                   , input buf_doc-line.prod-code , output v2-fact-qnty       , output v2-vat-pc
                                   , output v2-slt-pc            , output v2-sum-base         , output v2-sum-rubl
                                   , output v2-vat-base          , output v2-vat-rubl         , output v2-slt-base
                                   , output v2-slt-rubl          , output v2-road-tax-base    , output v2-road-tax-rubl
                                   , output v2-transport-base    , output v2-transport-rubl   , output v2-other-base
                                   , output v2-other-rubl        , output v2-excise-base      , output v2-excise-rubl ).

    if gds-prop.empty-scale = no then do: /* это шкальный товар */
      FOR EACH buf_gds-dtl no-lock
        where buf_gds-dtl.artic     = buf_doc-line.artic
          AND buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          AND buf_gds-dtl.prod-code = buf_doc-line.prod-code
          AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
        :
        { gbl/gdsbcode.i buf_gds-obj.gds-code buf_gds-dtl.prt-code v-prt-b-code  no-error  }
        if error-status :error then do:
          message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
          undo, return error .
        end.

        if buf_doc-line.ext-doc-type = {&TDEDT_Inv} or buf_doc-line.ext-doc-type = {&TDEDT_Peresort} then do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty ) .
          if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * v1-sum-rubl / v1-fact-qnty ) .
          else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * v1-sum-base / v1-fact-qnty ) .
          if buf_doc-line.ext-doc-type <> {&TDEDT_Pri_Vnesh}         and
             buf_doc-line.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}      then do:
            if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * buf_gds-dtl.price-rubl ) .
            else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * buf_gds-dtl.price-base ) .
          end.
        end.
        else do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty ) .
          if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * v1-sum-rubl / v1-fact-qnty ) .
          else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * v1-sum-base / v1-fact-qnty ) .
          if buf_doc-line.ext-doc-type <> {&TDEDT_Pri_Vnesh}         and
             buf_doc-line.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}      then do:
            if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * buf_gds-dtl.price-rubl ) .
            else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * buf_gds-dtl.price-base ) .
            if   buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
              or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
              or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
              or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            then do:
              if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code,  buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl ) .
              else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code,  buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base ) .
            end.
          end.
        end.
      end.
    end.

    if buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh}      or
       buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or
       buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}   or
       buf_doc-line.ext-doc-type = {&TDEDT_Ras_Perem}      or
       buf_doc-line.ext-doc-type = {&TDEDT_Spi_Vnesh}      or
       buf_doc-line.ext-doc-type = {&TDEDT_Spi_Prvo}       then
      assign
        v1-fact-qnty  = - v1-fact-qnty
        v1-sum-rubl   = - v1-sum-rubl
        v1-sum-base   = - v1-sum-base
        v2-sum-rubl   = - v2-sum-rubl
        v2-sum-base   = - v2-sum-base
        v2-other-rubl = - v2-other-rubl
        v2-other-base = - v2-other-base
      .

    run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-fact-qnty) .
    if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-sum-rubl) .
    else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-sum-base) .
    if buf_doc-line.ext-doc-type <> {&TDEDT_Pri_Vnesh} and  buf_doc-line.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}  then do:
      if   buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
        or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
        or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
        or buf_doc-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        if x-SET_val_TYPE = 1  then do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-rubl) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-rubl * 100 / v2-sum-rubl) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 5, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-rubl) .
        end.
        else do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-base) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-base * 100 / v2-sum-base) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 5, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-base) .
        end.
      end.
      else do:
        if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-rubl) .
        else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-base) .
      end.
    end.
/*    end.*/
  end.

  /* ***************************************************************************************** */
  /* нужны обороты ПЕРЕОЦЕНКА */
  assign
    v1-sum-rubl = 0
    v2-sum-rubl = 0
  .
  if buf_goods.gds-type = {&gds-office} then assign line1 = {&arh-cgdt-service} .
  else                                       assign line1 = {&arh-cgdt} .

  if use-column[67] = yes then do: /* переоценка */
    run GetEndSum (input (line1 + {&TDEDT_Overturn}) ,output v1-sum-rubl ) .
    run GetBegSum (input (line1 + {&TDEDT_Overturn}) ,output v2-sum-rubl ) .
    run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Overturn}, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .
  end.

  run GetEndSum (input (line1 + {&TDEDT_Ras_Vnesh}) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + {&TDEDT_Ras_Vnesh}) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh}, -1, gds-prop.b-code, v2-sum-rubl - v1-sum-rubl) .
  run GetEndSum (input (line1 + {&TDEDT_Ras_Vnesh_Kass}) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + {&TDEDT_Ras_Vnesh_Kass}) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Ras_Vnesh_Kass}, -1, gds-prop.b-code, v2-sum-rubl - v1-sum-rubl) .
  run GetEndSum (input (line1 + {&TDEDT_Vozvrat_Vnesh}) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + {&TDEDT_Vozvrat_Vnesh}) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh}, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .
  run GetEndSum (input (line1 + {&TDEDT_Vozvrat_Vnesh_Kass}) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + {&TDEDT_Vozvrat_Vnesh_Kass}) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, {&TDEDT_Vozvrat_Vnesh_Kass}, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .

/* $Workfile$   E n d */