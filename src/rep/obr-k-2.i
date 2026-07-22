/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

дл€ детал. оборотки

јвтор: ƒемин јлексей —ергеевич
ƒата создани€: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".
  /* остатки */
  /* нужны остатки на конец в ценах продажи */
  if use-column[6] = yes or use-column[7] = yes or use-column[51] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-crsa}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign  gds-prop.EndWay-SaleSum = gds-prop.EndWay-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.EndWay-SaleSum  = gds-prop.EndWay-SaleSum + buf_stk-line.sum-base .
    end.
  end.
  /* нужны остатки на конец в учет. ценах */
  if use-column[7] = yes or use-column[32] = yes or use-column[13] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-cost}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        assign
          gds-prop.EndWay-Qnty    = gds-prop.EndWay-Qnty  +  buf_stk-line.fact-qnty
          gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum + buf_stk-line.sum-rubl
        .
        if no-nds = yes then assign gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum - buf_stk-line.VAT-rubl .
      end .
      else do:
        assign
          gds-prop.EndWay-Qnty    = gds-prop.EndWay-Qnty  +  buf_stk-line.fact-qnty
          gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum + buf_stk-line.sum-base
        .
        if no-nds = yes then assign gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum - buf_stk-line.VAT-base .
      end .
    end.
  end.
  /* нужны остатки на начало в ценах продажи */
  if use-column[6] = yes or use-column[50] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-crsa}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order  <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.StartWay-SaleSum = gds-prop.StartWay-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.StartWay-SaleSum = gds-prop.StartWay-SaleSum + buf_stk-line.sum-base .
    end.
  end.
  /* нужны остатки на начало в учет. ценах */
  if use-column[12] = yes or use-column[31] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-cost}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        assign
          gds-prop.StartWay-Qnty  = gds-prop.StartWay-Qnty + buf_stk-line.fact-qnty
          gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum + buf_stk-line.sum-rubl
        .
        if no-nds = yes then assign gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum - buf_stk-line.VAT-rubl .
      end .
      else do:
        assign
          gds-prop.StartWay-Qnty  = gds-prop.StartWay-Qnty + buf_stk-line.fact-qnty
          gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum + buf_stk-line.sum-base
        .
        if no-nds = yes then assign gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum - buf_stk-line.VAT-base .
      end .
    end.
  end.
  /* а теперь остатки на альтернативных объектах */
  assign gds-prop.Alt-RestEnd-Qnty = 0 .
  if RADIO-AltObj = 2 then do :  /* все */
    for each buf_clients no-lock
    :
      find first b_obj-list no-lock
        where b_obj-list.obj-type = buf_clients.obj-type
          and b_obj-list.obj-code = buf_clients.obj-code
        no-error .
      if available b_obj-list then next .

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_clients.obj-type
          and buf_stk-line.obj-code  = buf_clients.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          gds-prop.Alt-RestEnd-Qnty = gds-prop.Alt-RestEnd-Qnty + buf_stk-line.fact-qnty
        .
      end.
    end.
  end.
  else do:
    if RADIO-AltObj = 3 then do :  /* выбран список */
      assign p-num = num-entries( AltObj-list ) .
      do ii = 1 to p-num by 2 :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = entry( ii, AltObj-list )
            and buf_stk-line.obj-code  = integer( entry( ii + 1 , AltObj-list ))
            and buf_stk-line.artic     = buf_gds-obj.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-cost}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order < v-fact-order-end
          use-index category no-error .

        if available buf_stk-line then do:
          assign
            gds-prop.Alt-RestEnd-Qnty = gds-prop.Alt-RestEnd-Qnty + buf_stk-line.fact-qnty
          .
       end.
      end.
    end.
  end.

  /* надо считать свободно и резерв на сегодн€ */
  if   use-column[89] = yes or use-column[90] = yes or use-column[91] = yes or use-column[92] = yes or use-column[93] = yes or use-column[94] = yes or use-column[95] = yes or use-column[96] = yes then do:
    /* свободно */
    assign
      gds-prop.Free-Qnty = gds-prop.Free-Qnty + buf_gds-obj.free-qnty
    .
    run rep/r-obrt12.p (
      input x-SET_val_TYPE,
      input v-fact-order-end,
      input buf_gds-obj.free-qnty,
      input buf_gds-obj.obj-type,
      input buf_gds-obj.obj-code,
      input buf_gds-obj.prod-type,
      input buf_gds-obj.prod-code,
      input buf_gds-obj.artic,
      input-output gds-prop.Free-CostSum,
      input-output gds-prop.Free-SaleSum,
      input-output gds-prop.Res-Qnty,
      input-output gds-prop.Res-CostSum,
      input-output gds-prop.Res-DocSum,
      input-output gds-prop.Res-SaleSum,
      input-output gds-prop.Res-DiscntSum
      ) .
  end.

/* $Workfile$   E n d */