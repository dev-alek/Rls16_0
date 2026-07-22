/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ќтчет о динамике реализации

јвтор: ƒемин јлексей —ергеевич
ƒата создани€: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .

  /* остатки на начало периода и приход-расход за весь период */
  find first temp-sum where temp-sum.num = 0 and temp-sum.gds-code = - 3 .
  run GetValTovar in this-procedure (input {&arh-crsa}, input v-fact-order-start, output temp-sum.ostat) .
  /* продажи по кассе */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.rashod = tmp1 - tmp2 .
  /* продажи */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
  /* возвраты по кассе */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
  /* возвраты */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
  /* приход */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Pri_Vnesh}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Pri_Vnesh}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.prihod = temp-sum.prihod - tmp1 + tmp2 .
  /* возвраты поставщику */
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_VP}), input v-fact-order-start, output tmp1) .
  run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_VP}), input v-fact-order-end,   output tmp2) .
  assign     temp-sum.prihod = temp-sum.prihod - tmp1 + tmp2 .

  /* а теперь по всем периодам */
  for each temp-date :
    find first temp-sum where temp-sum.num = temp-date.num and temp-sum.gds-code = - 3 .
    run GetValTovar in this-procedure (input {&arh-crsa}, input temp-date.fo2, output temp-sum.ostat) .
    /* продажи по кассе */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.rashod = tmp1 - tmp2 .
    /* продажи */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
    /* возвраты по кассе */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
    /* возвраты */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Vozvrat_Vnesh}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.rashod = temp-sum.rashod + tmp1 - tmp2 .
    /* приход */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Pri_Vnesh}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Pri_Vnesh}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.prihod = temp-sum.prihod - tmp1 + tmp2 .
    /* возвраты поставщику */
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_VP}), input temp-date.fo1, output tmp1) .
    run GetValTovar in this-procedure (input ({&arh-csdt} + {&TDEDT_Ras_Vnesh_VP}), input temp-date.fo2, output tmp2) .
    assign     temp-sum.prihod = temp-sum.prihod - tmp1 + tmp2 .
  end.

  /* ****************************************************************************************** */

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  assign no-null = no .
  for each temp-sum where temp-sum.gds-code = - 3 :
    if temp-sum.prihod <> 0 or temp-sum.rashod <> 0 or ( null-obort and temp-sum.ostat <> 0) then do:
      assign no-null = yes .
      leave.
    end.
  end.

  if no-null then do: /*  надо учитывать */
    find first temp-tovar
      where temp-tovar.artic        = buf_gds-obj.artic
        and temp-tovar.prod-type    = buf_gds-obj.prod-type
        and temp-tovar.prod-code    = buf_gds-obj.prod-code
    no-error .
    if available temp-tovar then do:
      find first temp-sum where temp-sum.num = 0 and temp-sum.gds-code = - 3 .
      assign
        temp-tovar.ostat-beg = temp-tovar.ostat-beg + temp-sum.ostat
        temp-tovar.prihod    = temp-tovar.prihod    + temp-sum.prihod
        temp-tovar.rashod    = temp-tovar.rashod    + temp-sum.rashod
      .
      for each temp-sum where temp-sum.gds-code = temp-tovar.gds-code :
        find first buf_temp-sum where buf_temp-sum.num = temp-sum.num and buf_temp-sum.gds-code = - 3 .
        assign
          temp-sum.prihod = temp-sum.prihod + buf_temp-sum.prihod
          temp-sum.rashod = temp-sum.rashod + buf_temp-sum.rashod
          temp-sum.ostat  = temp-sum.ostat  + buf_temp-sum.ostat
          tmp1 = temp-sum.ostat
        .
      end.
      assign temp-tovar.ostat = tmp1 .
    end.
    else do:
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
      create temp-tovar .
      { gbl/gdsbcode.i  buf_goods.gds-code  ?  temp-tovar.b-code  no-error }
      assign
        temp-tovar.artic     = buf_goods.artic
        temp-tovar.prod-type = buf_goods.prod-type
        temp-tovar.prod-code = buf_goods.prod-code
        temp-tovar.grp-name  = trim( buf_goods.grp-name )
        temp-tovar.unit-base = buf_goods.unit-base
        temp-tovar.gds-code  = buf_goods.gds-code
      .
      if g#gds-engl then assign temp-tovar.gds-name = buf_goods.engl-name.
      else               assign temp-tovar.gds-name = buf_goods.gds-name.

      find first temp-sum where temp-sum.num = 0 and temp-sum.gds-code = - 3 .
      assign
        temp-tovar.ostat-beg =  temp-sum.ostat
        temp-tovar.prihod    =  temp-sum.prihod
        temp-tovar.rashod    =  temp-sum.rashod
      .
      for each buf_temp-sum where buf_temp-sum.num > 0 and buf_temp-sum.gds-code = - 3 use-index pi .
        create temp-sum .
        assign
          temp-sum.gds-code = temp-tovar.gds-code
          temp-sum.num      = buf_temp-sum.num
          temp-sum.prihod   = buf_temp-sum.prihod
          temp-sum.rashod   = buf_temp-sum.rashod
          temp-sum.ostat    = buf_temp-sum.ostat
          tmp1 = temp-sum.ostat
        .
      end.
      assign temp-tovar.ostat = tmp1 .
    end.

    case SortType:
      when 4 then assign temp-tovar.sort-val = temp-tovar.ostat-beg . /*"по остаткам на начало".*/
      when 5 then assign temp-tovar.sort-val = temp-tovar.prihod .    /*"по приходу".*/
      when 6 then assign temp-tovar.sort-val = temp-tovar.rashod .    /*"по реализации".*/
      when 7 then assign temp-tovar.sort-val = temp-tovar.ostat .     /*"по остаткам на конец".*/
    end case.

  end.

  for each temp-sum where temp-sum.gds-code = - 3 :
    assign  temp-sum.prihod = 0  temp-sum.rashod = 0  temp-sum.ostat = 0 .
  end.


/* $Workfile$ e n d */