/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .

  if is-real then do:  /* накладные */
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.

        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }

        if buf_trn-doc.fact-order < v-fact-order-start then do:  /* остаток на начало по договору */
          case buf_trn-doc.ext-doc-type :
            when {&TDEDT_Ras_Vnesh} or
            when {&TDEDT_Ras_Vnesh_Kass} or
            when {&TDEDT_Spi_Vnesh} or
            when {&TDEDT_Spi_Prvo} or
            when {&TDEDT_Ras_Vnesh}  or
            when {&TDEDT_Inv}  or
            when {&TDEDT_Peresort} then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when {&TDEDT_Vozvrat_Vnesh} or
            when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:  /* оборот по договору */
          case buf_trn-doc.ext-doc-type :
            when {&TDEDT_Ras_Vnesh} or
            when {&TDEDT_Ras_Vnesh_Kass} or
            when {&TDEDT_Spi_Vnesh} or
            when {&TDEDT_Spi_Prvo} or
            when {&TDEDT_Ras_Vnesh}  or
            when {&TDEDT_Inv}  or
            when {&TDEDT_Peresort} then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
              { gbl/docextnm.i  temp-sum.num temp-sum.styp  }
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when {&TDEDT_Vozvrat_Vnesh} or
            when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
              { gbl/docextnm.i  temp-sum.num temp-sum.styp  }
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.

  if is-fo then do: /* фин.обязательства */
    /* остаток на начало по договору */
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = {&income}
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = {&expense} then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .

    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = {&fact}
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do: /* без договора */
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.

      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .

      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .

      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .

    end.
  end.

  if is-fin then do: /* платежи */
    /* остаток на начало по договору */
    run CalcOstatFin(input {&income-cashless}  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input {&expense-cashless} , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input {&income-cash}   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input {&expense-cash}  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input {&income-payoff} , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input {&expense-payoff}, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = {&expense} then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .

    /* оборот по договору */
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = {&fin-fact}
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do: /* без договора */
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .    
      
      if buf_fin-doc.fin-ext-doc-type = {&income-cashless} or buf_fin-doc.fin-ext-doc-type = {&income-cash} or buf_fin-doc.fin-ext-doc-type = {&income-payoff} then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = {&expense} then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.

  /* проверка на 0 и удаление пустых */
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
/* $Workfile$ e n d */