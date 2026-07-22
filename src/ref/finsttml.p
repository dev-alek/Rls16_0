block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finsttml.p $
$Archive: ref/finsttml.p $

Сохранение изменений в строке выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/29/05
Author: Bakhtadze Natalya
Creation date: 08/29/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-silent                       as logical no-undo .
define input-output parameter p-rid   as recid no-undo .
define input parameter p-mode         as character no-undo .
define input parameter p-host-code    like ub.fin-statement-line.host-code no-undo .
define input parameter p-sttm-code    like ub.fin-statement-line.sttm-code no-undo .
define input parameter p-fin-doc-code like ub.fin-statement-line.fin-doc-code no-undo .
define input parameter p-pay-date     like ub.fin-statement-line.pay-date no-undo .
define input parameter p-prn-doc-code like ub.fin-statement-line.prn-doc-code no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-statement-line.fin-ext-doc-type no-undo .
define input parameter p-bik          like ub.fin-statement-line.rp-bik no-undo .
define input parameter p-bank-name    like ub.fin-statement-line.rp-bank-name no-undo .
define input parameter p-bank-city    like ub.fin-statement-line.rp-bank-city no-undo .
define input parameter p-c-schet      like ub.fin-statement-line.rp-c-schet no-undo .
define input parameter p-r-schet      like ub.fin-statement-line.rp-r-schet no-undo .
define input parameter p-cli-name     like ub.fin-statement-line.rp-name no-undo .
define input parameter p-inn          like ub.fin-statement-line.rp-inn no-undo .
define input parameter p-kpp          like ub.fin-statement-line.rp-kpp no-undo .
define input parameter p-sum-doc  like ub.fin-statement-line.sum-doc no-undo .
define input parameter p-author as character no-undo .
define input parameter p-ps as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finsttml.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finsttml.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке выписки".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable v-mes     as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
define variable v-sum-doc like ub.fin-statement-line.sum-doc no-undo .
define variable v-sum-base like ub.fin-statement-line.sum-base no-undo .
define variable v-sum-rubl like ub.fin-statement-line.sum-rubl no-undo .
define variable v-exch-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-base-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-base-code like ub.sysconf.base-code  no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-num-doc as integer no-undo .
define variable v-fin-ext-doc-type  like ub.fin-doc.fin-ext-doc-type no-undo .
define variable v-pay-date like ub.fin-statement-line.pay-date no-undo .
define variable v-rp-bik like ub.fin-statement-line.rp-bik no-undo .
define variable v-rp-bank-name like ub.fin-statement-line.rp-bank-name no-undo .
define variable v-rp-bank-city like ub.fin-statement-line.rp-bank-city no-undo .
define variable v-rp-c-schet like ub.fin-statement-line.rp-c-schet no-undo .
define variable v-rp-r-schet like ub.fin-statement-line.rp-r-schet no-undo .
define variable v-rp-name like ub.fin-statement-line.rp-name no-undo .
define variable v-rp-inn like ub.fin-statement-line.rp-inn no-undo .
define variable v-rp-kpp like ub.fin-statement-line.rp-kpp no-undo .


define buffer buf_fin-statement for ub.fin-statement .
define buffer buf_fin-statement-line for ub.fin-statement-line .
define buffer buf_fin-doc for ub.fin-doc.


_main:
do
on error undo, return error return-value
:

if NOT (p-mode = {&add-def} or p-mode = {&deletion}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова p-mode" p-mode
  view-as alert-box ERROR.
  return error '':U.
end.


FIND FIRST buf_fin-statement EXCLUSIVE-LOCK WHERE
           buf_fin-statement.host-code = p-host-code
       AND buf_fin-statement.sttm-code = p-sttm-code No-ERROR No-WAIT.
IF LOCKED buf_fin-statement then do:
  assign
  v-mes = "Запись ВЫПИСКИ занята, добавление/изменение строки невозможно".
  run err-mess in this-procedure ( input-output v-mes).
  undo _main, return error v-mes.
end.
IF NOT available buf_fin-statement then do:
  assign
  v-mes = "Не найденa выписка".
  run err-mess in this-procedure ( input-output v-mes).
  undo _main, return error v-mes.
end.
if buf_fin-statement.status_ <> {&fin-new} then do:
  assign
  v-mes = substitute("Выписка имеет статус &1, добавление/изменение строки невозможно", buf_fin-statement.status_).
  run err-mess in this-procedure ( input-output v-mes).
  undo _main, return error v-mes.
end.

if p-fin-doc-code > 0
then do:
  find first buf_fin-doc exclusive-lock where
          buf_fin-doc.host-code = p-host-code
       AND buf_fin-doc.fin-doc-code = p-fin-doc-code no-wait no-error.
  IF LOCKED buf_fin-statement then do:
    assign
    v-mes = substitute("Запись ПЛАТЕЖА (внутр.№&1) занята, добавление/исключение его невозможно"
                      , p-fin-doc-code)
    .
    run err-mess in this-procedure ( input-output v-mes).
    undo _main, return error v-mes.
  end.
  if p-author = '':u
  and buf_fin-doc.status_ <> {&fin-fact} then do:
    assign
    v-mes = substitute("ПЛАТЕЖ (внутр.№&1) имеет статус &2,&3добавление/исключение в ВЫПИСКУ возможно только при ИМПОРТЕ из системы КЛИЕНТ-БАНК"
                      , p-fin-doc-code
                      , buf_fin-doc.status_
                      , {&new-line}
                      )
    .
    run err-mess in this-procedure ( input-output v-mes).
    undo _main, return error v-mes.
  end.
  if p-author <> '':U
  and not (buf_fin-doc.status_ = {&fin-bank}
          or
          buf_fin-doc.status_ = {&fin-fact}) then do:
    assign
    v-mes = substitute("ПЛАТЕЖ (внутр.№&1) имеет статус &2,&3добавление/исключение в ВЫПИСКУ невозможно"
                      , p-fin-doc-code
                      , buf_fin-doc.status_
                      , {&new-line}
                      )
    .
    run err-mess in this-procedure ( input-output v-mes).
    undo _main, return error v-mes.
  end.
  if buf_fin-doc.sttm-code > 0 then do:
    assign
    v-mes = substitute("Платеж &1 (внутр.№ &2) уже включен в банковскую выписку &3 по фирме &4&5добавление строки невозможно"
                      , buf_fin-doc.prn-doc-code
                      , buf_fin-doc.fin-doc-code
                      , buf_fin-doc.sttm-code
                      , p-host-code
                      , {&new-line}
                      ).
    run err-mess in this-procedure ( input-output v-mes).
    undo _main, return error v-mes.
  END.
  if buf_fin-doc.fact-date < buf_fin-statement.start-date
  or buf_fin-doc.fact-date > buf_fin-statement.end-date then do:
    assign
    v-mes = substitute("Платеж &1 (внутр.№ &2) имеет дату факт &3&4и не может быть включен в банковскую выписку &5 по фирме &6 за &7-&8"
                      , buf_fin-doc.prn-doc-code
                      , buf_fin-doc.fin-doc-code
                      , buf_fin-doc.fact-date
                      , {&new-line}
                      , buf_fin-doc.sttm-code
                      , p-host-code
                      , string(buf_fin-statement.start-date, "99/99/9999")
                      , string(buf_fin-statement.end-date, "99/99/9999")
                      ).
    run err-mess in this-procedure ( input-output v-mes).
    undo _main, return error v-mes.
  end.

end.


DO ON ERROR UNDO, return '':U
   On STOP UNDO, return '':U:
  if p-mode = {&add-def} then do:
    find last buf_fin-statement-line no-lock where
            buf_fin-statement-line.host-code = p-host-code
        AND buf_fin-statement-line.sttm-code = p-sttm-code no-error.
    CREATE ub.fin-statement-line.
    ASSIGN
    ub.fin-statement-line.host-code     = p-host-code
    ub.fin-statement-line.sttm-code     = p-sttm-code
    ub.fin-statement-line.line-num      = (if available buf_fin-statement-line
                                           then buf_fin-statement-line.line-num else 0)  + 1
    ub.fin-statement-line.fin-doc-code  = (if available buf_fin-doc then buf_fin-doc.fin-doc-code else 0)
    ub.fin-statement-line.fin-ext-doc-type =  (if available buf_fin-doc
                                               then  buf_fin-doc.fin-ext-doc-type
                                               else  p-fin-ext-doc-type)
    ub.fin-statement-line.fin-doc-type = (if available buf_fin-doc
                                          then  buf_fin-doc.fin-doc-type
                                          else '':U)
    ub.fin-statement-line.fins-ext-doc-type = buf_fin-statement.fins-ext-doc-type
    ub.fin-statement-line.fins-doc-type = buf_fin-statement.fins-doc-type
    ub.fin-statement-line.prn-doc-code = (if available buf_fin-doc then buf_fin-doc.prn-doc-code else p-prn-doc-code)
    ub.fin-statement-line.ps = p-ps
    .
    if available buf_fin-doc then do:
      buf_fin-doc.sttm-code = p-sttm-code.
    end.
    assign p-rid = recid(ub.fin-statement-line).
  end.
  else do:
    FIND FIRST ub.fin-statement-line EXCLUSIVE-LOCK WHERE
              recid(ub.fin-statement-line) = p-rid No-WAIT No-ERROR.
    if locked ub.fin-statement-line then do:
      assign
      v-mes = substitute("Строка выписки занята").
      run err-mess in this-procedure ( input-output v-mes).
      undo _main, return error v-mes.
    end.
    if not avail ub.fin-statement-line then do:
      assign
      v-mes = substitute("Не найдена строка выписки").
      run err-mess in this-procedure ( input-output v-mes).
      undo _main, return error v-mes.
    end.
    if available buf_fin-doc then do:
      buf_fin-doc.sttm-code = 0.
    end.
  end.
  if p-fin-doc-code > 0 then do:
    if p-mode = {&add-def} then do:
      assign
      v-num-doc = 1
      v-sum-doc = buf_fin-doc.sum-doc
      v-sum-rubl = buf_fin-doc.sum-rubl
      v-sum-base = buf_fin-doc.sum-base
      v-fin-ext-doc-type = buf_fin-doc.fin-ext-doc-type
      v-pay-date = buf_fin-doc.pay-date
      v-rp-c-schet = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                      then buf_fin-doc.payer-c-schet
                      else buf_fin-doc.receiver-c-schet)
      v-rp-bik  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-bik
                   else buf_fin-doc.receiver-bik)
      v-rp-bank-name  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-bank-name
                   else buf_fin-doc.receiver-bank-name)
      v-rp-bank-city  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-bank-city
                   else buf_fin-doc.receiver-bank-city)
      v-rp-r-schet  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-r-schet
                   else buf_fin-doc.receiver-r-schet)
      v-rp-name  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-name
                   else buf_fin-doc.receiver-name)
      v-rp-inn  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-inn
                   else buf_fin-doc.receiver-inn)
      v-rp-kpp  = (if buf_fin-doc.fin-doc-type = {&income-cashless}
                   then buf_fin-doc.payer-kpp
                   else buf_fin-doc.receiver-kpp)
      .
    end.
    if p-mode = {&deletion} then do:
      assign
      v-num-doc = -1
      v-sum-doc = - ub.fin-statement-line.sum-doc
      v-sum-rubl = - ub.fin-statement-line.sum-rubl
      v-sum-base = - ub.fin-statement-line.sum-base
      v-fin-ext-doc-type = ub.fin-statement-line.fin-ext-doc-type
      .
    end.
  end.
  else do:
    assign
    v-fin-ext-doc-type = p-fin-ext-doc-type
    v-pay-date = p-pay-date
    v-rp-bik = p-bik
    v-rp-bank-name = p-bank-name
    v-rp-bank-city = p-bank-city
    v-rp-c-schet = p-c-schet
    v-rp-r-schet = p-r-schet
    v-rp-name = p-cli-name
    v-rp-inn = p-inn
    v-rp-kpp = p-kpp
    .
    { gbl/basecode.i buf_fin-statement.host-code v-base-code }
    if v-base-code <> 0 then do:
    { gbl/exchrate.i v-base-code p-pay-date v-base-rate v-base-scale v-curr-abbr }
    end.
    if buf_fin-statement.curr-code <> 0 then do:
      { gbl/exchrate.i buf_fin-statement.curr-code p-pay-date v-exch-rate v-exch-scale v-curr-abbr }
    end.
    assign
    v-sum-doc = p-sum-doc
    v-sum-rubl = (if buf_fin-statement.curr-code = 0
                  then v-sum-doc
                  else (p-sum-doc * v-exch-rate / v-exch-scale))
    v-sum-base = if v-base-code = 0
                  then v-sum-rubl
                  else (v-sum-rubl / v-base-rate * v-base-scale)
    v-num-doc = 1
    .
    if p-mode = {&deletion} then do:
      assign
      v-sum-doc = - v-sum-doc
      v-sum-rubl = - v-sum-rubl
      v-sum-base = - v-sum-base
      v-num-doc =  - v-num-doc
      .
    end.
  end.
  assign
  ub.fin-statement-line.rp-bik     = v-rp-bik
  ub.fin-statement-line.rp-bank-name = v-rp-bank-name
  ub.fin-statement-line.rp-bank-city = v-rp-bank-city
  ub.fin-statement-line.rp-c-schet = v-rp-c-schet
  ub.fin-statement-line.rp-r-schet = v-rp-r-schet
  ub.fin-statement-line.rp-name = v-rp-name
  ub.fin-statement-line.rp-inn = v-rp-inn
  ub.fin-statement-line.rp-kpp = v-rp-kpp
  .
  CASE v-fin-ext-doc-type:
    when {&FDEDT_income_cashless} then do:
      assign
      ub.fin-statement-line.pay-date = v-pay-date
      buf_fin-statement.in-sum-doc-th = buf_fin-statement.in-sum-doc-th + v-sum-doc
      ub.fin-statement-line.sum-doc = v-sum-doc
      buf_fin-statement.in-sum-rubl-th = buf_fin-statement.in-sum-rubl-th + v-sum-rubl
      ub.fin-statement-line.sum-rubl = v-sum-rubl
      buf_fin-statement.in-sum-base-th = buf_fin-statement.in-sum-base-th + v-sum-base
      ub.fin-statement-line.sum-base = v-sum-base
      .
      if p-author = '':U
      then do:
        assign
        buf_fin-statement.in-sum-doc = buf_fin-statement.in-sum-doc  + v-sum-doc
        buf_fin-statement.in-sum-rubl = buf_fin-statement.in-sum-rubl + v-sum-rubl
        buf_fin-statement.in-sum-base = buf_fin-statement.in-sum-base + v-sum-base
        .
      end.
    end.
    when {&FDEDT_expense_cashless} then do:
      assign
      ub.fin-statement-line.pay-date = v-pay-date
      ub.fin-statement-line.rp-c-schet = v-rp-c-schet
      buf_fin-statement.out-sum-doc-th = buf_fin-statement.out-sum-doc-th + v-sum-doc
      ub.fin-statement-line.sum-doc = v-sum-doc
      buf_fin-statement.out-sum-rubl-th = buf_fin-statement.out-sum-rubl-th + v-sum-rubl
      ub.fin-statement-line.sum-rubl = v-sum-rubl
      buf_fin-statement.out-sum-base-th = buf_fin-statement.out-sum-base-th + v-sum-base
      ub.fin-statement-line.sum-base = v-sum-base
      .
      if p-author = '':U then do:
        assign
        buf_fin-statement.out-sum-doc = buf_fin-statement.out-sum-doc + v-sum-doc
        buf_fin-statement.out-sum-rubl = buf_fin-statement.out-sum-rubl + v-sum-rubl
        buf_fin-statement.out-sum-base = buf_fin-statement.out-sum-base + v-sum-base
        .
      end.
    end.
  END CASE.
  assign
  buf_fin-statement.sum-doc-th = buf_fin-statement.in-sum-doc-th  - buf_fin-statement.out-sum-doc-th
  buf_fin-statement.sum-rubl-th = buf_fin-statement.in-sum-rubl-th  - buf_fin-statement.out-sum-rubl-th
  buf_fin-statement.sum-base-th = buf_fin-statement.in-sum-base-th  - buf_fin-statement.out-sum-base-th
  buf_fin-statement.end-sum-doc-th = buf_fin-statement.start-sum-doc-th  + buf_fin-statement.sum-doc-th
  buf_fin-statement.end-sum-rubl-th = buf_fin-statement.start-sum-rubl-th  + buf_fin-statement.sum-rubl-th
  buf_fin-statement.end-sum-base-th = buf_fin-statement.start-sum-base-th  + buf_fin-statement.sum-base-th
  buf_fin-statement.num-docs-th = buf_fin-statement.num-docs-th + v-num-doc
  .
  if p-author = '':U then do:
    assign
    buf_fin-statement.sum-doc = buf_fin-statement.in-sum-doc  - buf_fin-statement.out-sum-doc
    buf_fin-statement.sum-rubl = buf_fin-statement.in-sum-rubl  - buf_fin-statement.out-sum-rubl
    buf_fin-statement.sum-base = buf_fin-statement.in-sum-base  - buf_fin-statement.out-sum-base
    buf_fin-statement.end-sum-doc = buf_fin-statement.start-sum-doc  + buf_fin-statement.sum-doc
    buf_fin-statement.end-sum-rubl = buf_fin-statement.start-sum-rubl  + buf_fin-statement.sum-rubl
    buf_fin-statement.end-sum-base = buf_fin-statement.start-sum-base  + buf_fin-statement.sum-base
    buf_fin-statement.num-docs = buf_fin-statement.num-docs + v-num-doc
    .
  end.
  if p-author = {&cl-bank-1s} then do: /*этот клиент-банк ОБЩИЙ оборот не дает*/
    assign
    buf_fin-statement.sum-doc = buf_fin-statement.in-sum-doc  - buf_fin-statement.out-sum-doc
    buf_fin-statement.sum-rubl = buf_fin-statement.in-sum-rubl  - buf_fin-statement.out-sum-rubl
    buf_fin-statement.sum-base = buf_fin-statement.in-sum-base  - buf_fin-statement.out-sum-base
    .
  end.

  if p-mode = {&add-def} then dO:
    release ub.fin-statement-line no-error.
    if error-status:error then do:
      assign
      v-mes = substitute("Ошибка при сохранении строки выписки:&1&2&1&3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         ).
      run err-mess in this-procedure ( input-output v-mes).
      undo _main, return error v-mes.
    end.
  end.
  if p-mode = {&deletion} then do:
    assign
    .
    delete ub.fin-statement-line no-error.
    if error-status:error then do:
      assign
      v-mes = substitute("Ошибка при удалении строки выписки:&1&2&1&3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         ).
      run err-mess in this-procedure ( input-output v-mes).
      undo _main, return error v-mes.
    end.
    p-rid = ?.
  end.
END.
return '':U.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("ВЫПИСКА фирма &1 №&2 строка по документу &3:&4&5"
                   , p-host-code
                   , p-sttm-code
                   , p-prn-doc-code
                   , {&new-line}
                   , p-mes).
  if not p-silent then do:
    message
    p-mes view-as alert-box error .
  end.
END PROCEDURE.