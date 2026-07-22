/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок r-zapasr.p

Автор: Демин Алексей Сергеевич
Дата создания: 01/13/06
Author: Alexey Demin
Creation date: 01/13/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  if x-date-end < today then do:
    run partslib-init-temp-parts-by-factord in this-procedure( input buf_gds-obj.obj-type, input buf_gds-obj.obj-code, input buf_gds-obj.artic, input buf_gds-obj.prod-type, input buf_gds-obj.prod-code, input v-fact-order-end, input false ) .
  end.
  else do: /* на сегодня */
    run partslib-init-temp-parts in this-procedure( input buf_gds-obj.obj-type, input buf_gds-obj.obj-code, input buf_gds-obj.artic, input buf_gds-obj.prod-type, input buf_gds-obj.prod-code ) .
  end.
  for each temp-parts :
    if xShowZero = no and temp-parts.fact-qnty = 0 and temp-parts.free-qnty = 0 then next . /* пропускаем нули */

    if tog-obj = true then do: /* раздельно по объектам */
      find first temp-gds
        where temp-gds.prod-type = buf_gds-obj.prod-type
          and temp-gds.prod-code = buf_gds-obj.prod-code
          and temp-gds.artic     = buf_gds-obj.artic
          and temp-gds.in-code   = temp-parts.in-code
          and temp-gds.part-code = temp-parts.part-code
          and temp-gds.obj-type  = buf_gds-obj.obj-type
          and temp-gds.obj-code  = buf_gds-obj.obj-code
      no-error .
    end.
    else do:
      find first temp-gds
        where temp-gds.prod-type = buf_gds-obj.prod-type
          and temp-gds.prod-code = buf_gds-obj.prod-code
          and temp-gds.artic     = buf_gds-obj.artic
          and temp-gds.in-code   = temp-parts.in-code
          and temp-gds.part-code = temp-parts.part-code
      no-error .
    end.
    if not available temp-gds then do:
      run CreateGDS ( buf_gds-obj.artic, buf_gds-obj.prod-type, buf_gds-obj.prod-code, temp-parts.in-code, temp-parts.part-code, temp-parts.supp-type, temp-parts.supp-code) .
    end.

    /* определяем количество товара по признакам */
    /* на дату инициализации складского архива */
    run prdoclib-init-prt-obj-by-factord in this-procedure ( input buf_gds-obj.obj-type, input buf_gds-obj.obj-code, input buf_gds-obj.artic ,input buf_gds-obj.prod-type, input buf_gds-obj.prod-code, input v-fact-order-end, input false ) .
    /* определяем сумму в продажных ценах */
    run prdoclib-calc-temp-fact-sale in this-procedure (input buf_gds-obj.obj-type, input buf_gds-obj.obj-code, input buf_gds-obj.gds-code, input v-fact-order-end, input v-curr-r-b
      ,output v-cur-qnty             /* p-fact-qnty          */
      ,output v-cur-base             /* p-cur-base           */
      ,output v-cur-VAT-base         /* p-cur-VAT-base       */
      ,output v-cur-SLT-base         /* p-cur-SLT-base       */
      ,output v-cur-road-tax-base    /* p-cur-road-tax-base  */
      ,output v-cur-excise-base      /* p-cur-excise-base    */
      ) no-error .
    if error-status :error
    then do:
      message  vss-workfile vss-revision vss-description skip "Ошибка при вызове процедуры" skip view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      temp-gds.fact-qnty  = temp-gds.fact-qnty  + temp-parts.fact-qnty
      temp-gds.free-qnty  = temp-gds.free-qnty  + temp-parts.free-qnty
    .
    if x-SET_val_TYPE = 1 then do:
      if v-curr-r-b = {&r-b-base} then v-cur-base = v-cur-base * v-base-rate / v-base-scale .
      assign
        temp-gds.zak-sum  = temp-gds.zak-sum  + temp-parts.price-rubl * temp-parts.fact-qnty
/*        temp-gds.zak-sum  = temp-gds.zak-sum  + ABSOLUTE(tt-allsum.sum-dsc-rubl-acc)*/
/*        temp-gds.prod-sum = temp-gds.prod-sum + ABSOLUTE(tt-allsum.sum-dsc-rubl-cur)*/
      .
    end.
    else do:
      if v-curr-r-b <> {&r-b-base} then v-cur-base = v-cur-base * v-base-scale / v-base-rate .
      assign
        temp-gds.zak-sum  = temp-gds.zak-sum  + temp-parts.price-base * temp-parts.fact-qnty
/*        temp-gds.zak-sum  = temp-gds.zak-sum  + ABSOLUTE(tt-allsum.sum-dsc-base-acc)*/
/*        temp-gds.prod-sum = temp-gds.prod-sum + ABSOLUTE(tt-allsum.sum-dsc-base-cur)*/
      .
    end.
    assign temp-gds.prod-sum = temp-gds.prod-sum + abs (v-cur-base * temp-parts.fact-qnty / v-cur-qnty ) .
  end.

  if xShowZero = yes then do:  /* ищем партии расходной зоны */
    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.out-code  = {&output-code}
      :
      if tog-obj = true then do: /* раздельно по объектам */
        find first temp-gds
          where temp-gds.prod-type = buf_gds-obj.prod-type
            and temp-gds.prod-code = buf_gds-obj.prod-code
            and temp-gds.artic     = buf_gds-obj.artic
            and temp-gds.obj-type  = buf_gds-obj.obj-type
            and temp-gds.obj-code  = buf_gds-obj.obj-code
        no-error .
      end.
      else do:
        find first temp-gds
          where temp-gds.prod-type = buf_gds-obj.prod-type
            and temp-gds.prod-code = buf_gds-obj.prod-code
            and temp-gds.artic     = buf_gds-obj.artic
        no-error .
      end.
      if not available temp-gds then do:
        run CreateGDS ( buf_gds-obj.artic, buf_gds-obj.prod-type, buf_gds-obj.prod-code, buf_parts.in-code, buf_parts.part-code, buf_parts.supp-type, buf_parts.supp-code) .
        if x-SET_val_TYPE = 1 then assign temp-gds.zak-price = buf_parts.price-rubl .
        else                       assign temp-gds.zak-price = buf_parts.price-base .
      end.
    end.
  end.
  /* ожидаемые приходы */
  run CalcWaitQnty (input {&TDEDT_Pri_Vnesh} ) .
  run CalcWaitQnty (input {&TDEDT_Pri_Perem} ) .
  run CalcWaitQnty (input {&TDEDT_Vozvrat_Vnesh} ) .
  run CalcWaitQnty (input {&TDEDT_Vozvrat_Vnesh_Kass} ) .
  run CalcWaitQnty (input {&TDEDT_Pri_Prvo} ) .
  run CalcWaitQnty (input {&TDEDT_Inv} ) .
  run CalcWaitQnty (input {&TDEDT_Peresort} ) .

/*   {&TDEDT_Inv})             */
/*   {&TDEDT_Corr_Acc_Price})  */
/*   {&TDEDT_Pri_Perem})       */
/*   {&TDEDT_Vozvrat_Perem})   */
/*   {&TDEDT_Pri_Prvo})        */

/* $Workfile$ e n d */