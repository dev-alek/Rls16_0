block-level on error undo, throw.
/*

$Revision: d6caaa2cda62, 3048, rls $
$Author: EShklyar $
$Date: Чт май 12 16:29:49 2022 +0300 $
$Workfile: findoc0.p $
$Archive: ref/findoc0.p $

Сохранение изменений в платежных документах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/15/03
Author: Bakhtadze Natalya
Creation date: 11/15/03

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

{ ref/fndocip.i }

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .
{&all-fin-doc-params-doc-status-define}
{&all-fin-doc-params-doc-status-define-2}
define temp-table tt0-fin-doc-tax no-undo like ub.fin-doc-tax.
define input parameter table for tt0-fin-doc-tax.
define temp-table tt0-fin-doc-attr no-undo like ub.fin-doc-attr.
define input parameter table for tt0-fin-doc-attr.
define input parameter p-save-payment as logical no-undo .
define temp-table tt0-payment no-undo like ub.payment.
define input parameter table for tt0-payment.


define variable vss-revision    as character no-undo init "$Revision: d6caaa2cda62, 3048, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Чт май 12 16:29:49 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoc0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoc0.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в платежных документах".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num as integer no-undo init -1.
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-correct-inn as logical no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-acc as decimal no-undo .
define variable v-year-start-date as date no-undo .
define variable v-year-end-date as date no-undo .
define variable v-is-obj    as logical no-undo .
define variable accum-rubl as decimal no-undo .
define variable accum-base as decimal no-undo .
define variable accum-doc as decimal no-undo .
define variable accum-contr as decimal no-undo .
define variable v-type as character no-undo .
define variable v-author  as character no-undo .
/*кто запрашивает изменение документа - может быть '' или 'cl-bank:U*/
define variable v-ret-mess as character no-undo .
define variable v-pmnt-code as character no-undo .
define variable v-full-pmnt-code as character no-undo .
define variable v-found as logical no-undo .
define variable v-cash-book-place as character no-undo .
define variable v-cash-book as integer no-undo .
define variable v-is-auto-obj as logical no-undo .
define variable v-flag-shift as logical no-undo .

define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_contract  for ub.contract.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_clients-obj for ub.clients.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-ob      for ub.fin-ob.
define buffer buf0_payment for ub.payment.

{ cmp/trg-def.i }
{ gbl/clntattr.i }
{ str/lib-farh.i }
{ ref/fd-attr.i " " tt0-fin-doc-attr }
{ str/lib-trn.i }

if entry(1, p-mode, {&delim-par}) <> {&add-def}
and entry(1, p-mode, {&delim-par}) <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
assign
v-author = (if num-entries(p-mode, {&delim-par}) > 1
           then entry(2, p-mode, {&delim-par})
           else '':U)
p-mode = entry(1, p-mode, {&delim-par})
.

{ gbl/curdbnum.i v-db-num }

find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then do:
  run err-mess in this-procedure ( substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.
if p-obj-type <> "":U
or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj
  or (p-obj-type <> {&shop} and p-obj-type <> {&stock})
  then do:
    run err-mess in this-procedure ( substitute("Не найден объект &1&2", p-obj-type, p-obj-code), output v-ret-mess).
    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).
  end.
  if buf_clients-obj.host-code <> p-host-code then do:
    run err-mess in this-procedure ( substitute("Объект &1&2 принадлежит фирме &3, а платеж принадлежит фирме &4"
                             , p-obj-type, p-obj-code, buf_clients-obj.host-code , p-host-code), output v-ret-mess).
    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).
  end.
  { gbl/objdbnum.i buf_clients-obj.obj-type buf_clients-obj.obj-code v-obj-db-num }
  /*только там может быть не пусто v-cash-book-place */
/*  { gbl/cashbook.i buf_clients-obj.obj-type buf_clients-obj.obj-code v-cash-book no-error }*/

end.

assign
v-cash-book-place = p-trn-doc-code.
if not (p-obj-type = '' and p-obj-code = 0)
and v-obj-db-num = g#db-num then do:
  define variable l-shift-on as logical no-undo .
  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
  }
end. /*if not (p-obj-type = '' and p-obj-code = 0)*/

assign
v-base-code = buf_sysconf.base-code
.
if p-prn-doc-code <> "":U and p-prn-doc-code <> "тех_":U
then do:
  assign
  v-year-start-date = date(1, 1, year(p-doc-date))
  v-year-end-date = date(12, 31, year(p-doc-date))
  .
  IF can-find(first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = p-host-code
                AND buf_fin-doc.prn-doc-code = p-prn-doc-code
                AND buf_fin-doc.fin-doc-type = p-fin-doc-type
                AND (buf_fin-doc.doc-date >= v-year-start-date
                     and
                     buf_fin-doc.doc-date <= v-year-end-date)
                AND (p-mode = {&add-def} OR p-doc-rec <> recid(buf_fin-doc))
                AND (p-fin-doc-type <> {&income-cashless}
                     OR (buf_fin-doc.payer-type = p-payer-type AND buf_fin-doc.payer-code = p-payer-code)
                    )
                ) then do:
    if p-fin-doc-type = {&income-cashless} then do:
      run err-mess in this-procedure ( substitute("Уже есть ПЛАТЕЖ с номером &1 для фирмы &2 от плательщика &3&4 за &5 год"
                              , p-prn-doc-code
                              , p-host-code
                              , p-payer-type
                              , p-payer-code
                              , year(p-doc-date)), output v-ret-mess).
    end.
    else do:
      run err-mess in this-procedure ( substitute("Уже есть ПЛАТЕЖ с номером &1 для фирмы &2 за &3 год", p-prn-doc-code, p-host-code, year(p-doc-date)), output v-ret-mess).
    end.
    undo, return error (if p-silent = no then "prn-doc-code":U else v-ret-mess).
  end.
end.
if p-doc-date = ? then do:
  run err-mess in this-procedure ( "Неверная дата составления ПЛАТЕЖА", output v-ret-mess).
  undo, return error (if p-silent = no then "doc-date":U else v-ret-mess).
end.
if p-curr-code <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( substitute("Не надена валюта с кодом &1", p-curr-code), output v-ret-mess).
    undo, return error (if p-silent = no then "curr-code":U else v-ret-mess) .
  end.
end.
if p-contract-curr <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-contract-curr no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( substitute("Не надена валюта контракта с кодом &1", p-contract-curr), output v-ret-mess).
    undo, return error (if p-silent = no then "contract-curr":U else v-ret-mess).
  end.
end.
if p-receiver-name = "":U then do:
  run err-mess in this-procedure ( "Имя ПОЛУЧАТЕЛЯ не может быть пустым", output v-ret-mess).
  undo, return error (if p-silent = no then "receiver-name":U else v-ret-mess).
end.
/*if p-payer-name = "":U then do:
  run err-mess in this-procedure ( "Имя ПЛАТЕЛЬЩИКА не может быть пустым", output v-ret-mess).
  undo, return error (if p-silent = no then "payer-name":U else v-ret-mess).
end.*/
if p-receiver-inn <> "":U then do:
  run gbl/keyinn.p ( input p-receiver-inn
                    ,input p-receiver-type
                    ,input p-receiver-code
                    ,input ? /*ПЮОЮЛ */
                    ,output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    run err-mess in this-procedure ( substitute("Неверный {&abbr_inn_allshift} ПОЛУЧАТЕЛЯ &1 &2", p-receiver-inn, return-value), output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-inn":U else v-ret-mess).
  end.
end.
if p-payer-inn <> "":U then do:
  run gbl/keyinn.p ( input p-payer-inn
                    ,input p-payer-type
                    ,input p-payer-code
                    ,input ? /*ПЮОЮЛ*/
                    ,output v-correct-inn) no-error .
  if error-status:error or not v-correct-inn then do:
    run err-mess in this-procedure (substitute("Неверный {&abbr_inn_allshift} ПЛАТЕЛЬЩИКА &1 &2",  p-payer-inn, return-value), output v-ret-mess).
    undo, return error (if p-silent = no then "payer-inn":U else v-ret-mess).
  end.
end.
if p-fin-doc-type = {&income-cash} or
   p-fin-doc-type = {&income-cashless} or
   p-fin-doc-type = {&income-payoff}
   then do:
  if p-receiver-code <> p-host-code then do:
    run err-mess in this-procedure (substitute("Неверные ПОЛУЧАТЕЛЬ &1 &2: ПОЛУЧАТЕЛЬ для платежа &3 должен быть &4&5"
                             , p-receiver-type
                             , p-receiver-code
                             , p-fin-doc-type
                             , {&cmp}
                             , p-host-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code":U else v-ret-mess).
  end.
end.
find first buf_clients no-lock where
            buf_clients.obj-type = p-receiver-type
        AND buf_clients.obj-code = p-receiver-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure (substitute("Не найден ПОЛУЧАТЕЛЬ &1 &2", p-receiver-type, p-receiver-code) , output v-ret-mess).
  undo, return error (if p-silent = no then "receiver-code":U else v-ret-mess).
end.
if p-receiver-code-schet <> 0 then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-receiver-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure (substitute("Не найден СЧЕТ ПОЛУЧАТЕЛЯ &1&2: фирма &3 код счета &4", p-receiver-type, p-receiver-code, p-host-code, p-receiver-code-schet) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure (substitute("Валюта СЧЕТА ПОЛУЧАТЕЛЯ &1&2: фирма &3 код счета &4 валюта &5 - не совпадает с валютой ПЛАТЕЖА &6",
    p-receiver-type, p-receiver-code,
    p-host-code, p-payer-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "receiver-code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = p-receiver-type
          and
          buf_fin-schet.cli-code = p-receiver-code) then do:
    run err-mess in this-procedure (substitute("СЧЕТ ПОЛУЧАТЕЛЯ принадлежит &1&2 - не совпадает с ПОЛУЧАТЕЛЕМ &3&4"
                                               ,buf_fin-schet.cli-type
                                               ,buf_fin-schet.cli-code
                                               ,p-receiver-type
                                               ,p-receiver-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "receiver-code-schet":U else v-ret-mess).
  end.

end.
if p-fin-doc-type = {&expense-cash}
or p-fin-doc-type = {&expense-cashless}
or p-fin-doc-type = {&expense-payoff}
   then do:
  if p-payer-code <> p-host-code then do:
    run err-mess in this-procedure (substitute("Неверный ПЛАТЕЛЬЩИК &1 &2: ПЛАТЕЛЬЩИК для платежа &3 должен быть &4&5"
                             , p-payer-type
                             , p-payer-code
                             , p-fin-doc-type
                             , {&cmp}
                             , p-host-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "payer-code":U else v-ret-mess).
  end.
end.
find first buf_clients no-lock where
            buf_clients.obj-type = p-payer-type
        AND buf_clients.obj-code = p-payer-code no-error .
if not available buf_clients then do:
  run err-mess in this-procedure (substitute("Не найден ПЛАТЕЛЬЩИК &1 &2", p-payer-type, p-payer-code), output v-ret-mess).
  undo, return error (if p-silent = no then "payer-code":U else v-ret-mess).
end.
if p-payer-code-schet <> 0 then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-payer-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure (substitute("Не найден СЧЕТ ПЛАТЕЛЬЩИКА &1&2: фирма &3 код счета &4", p-payer-type, p-payer-code, p-host-code, p-payer-code-schet) , output v-ret-mess).
    undo, return error (if p-silent = no then "payer-code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure (substitute("Валюта СЧЕТА ПЛАТЕЛЬЩИКА &1&2: фирма &3 код счета &4 валюта &5 - не совпадает с валютой ПЛАТЕЖА &6",
    p-payer-type, p-payer-code,
    p-host-code, p-payer-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = p-payer-type
          and
          buf_fin-schet.cli-code = p-payer-code) then do:
    run err-mess in this-procedure (substitute("СЧЕТ ПЛАТЕЛЬЩИКА принадлежит &1&2 - не совпадает с ПЛАТЕЛЬЩИКОМ &3&4"
                                               ,buf_fin-schet.cli-type
                                               ,buf_fin-schet.cli-code
                                               ,p-payer-type
                                               ,p-payer-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code-schet":U else v-ret-mess).
  end.
end.
if p-payer-type = p-receiver-type
and p-payer-code = p-receiver-code then do:
    run err-mess in this-procedure (substitute("ПЛАТЕЛЬЩИК и ПОЛУЧАТЕЛЬ - не могут быть одной и той же организацией/физ.лицом (&1&2)"
                                               ,p-payer-type
                                               ,p-payer-code) , output v-ret-mess).
    undo, return error (if p-silent = no then  "payer-code":U else v-ret-mess).
end.
if p-contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.contract-code = p-contract-code no-error .
  if not available buf_contract then do:
    run err-mess in this-procedure (substitute("Не найден договор: фирма &1 код договора &2", p-host-code, p-contract-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "contract-code":U  else v-ret-mess).
  end.
  if p-contract-curr <> buf_contract.curr-code then do:
    run err-mess in this-procedure (substitute("Неверная валюта договора : фирма &1 код договора &2 - в договоре &3, а в платеже &4", p-host-code, p-contract-code, buf_contract.curr-code, p-contract-curr), output v-ret-mess ).
    undo, return error (if p-silent = no then  "contract-curr":U  else v-ret-mess).
  end.
end.
if p-cor-acc <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.host-code = p-host-code
        AND buf_fin-code-cor-acc.fin-code = p-cor-acc no-error .
  if not available buf_fin-code-cor-acc then do:
    run err-mess in this-procedure (substitute("Не найден корреспондирующий счет: фирма &1 внутр. код счета &2", p-host-code, p-cor-acc), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc":U  else v-ret-mess).
  end.
/*  if buf_fin-code-cor-acc.code-value <> p-cor-acc-value then do:                                                                                                                                                                        */
/*    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код корреспондирующего счета и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc, p-cor-acc-value), output v-ret-mess ).*/
/*    undo, return error (if p-silent = no then  "cor-acc-value":U  else v-ret-mess).                                                                                                                                                     */
/*  end.                                                                                                                                                                                                                                  */
  if buf_fin-code-cor-acc.status_ <> integer({&current-status-int}) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус корр счета: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc, p-cor-acc-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U  else v-ret-mess).
  end.

end.
if p-cor-acc1 <> 0 then do:
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.host-code = p-host-code
        AND buf_fin-code-cor-acc.fin-code = p-cor-acc1 no-error .
  if not available buf_fin-code-cor-acc then do:
    run err-mess in this-procedure (substitute("Не найден корреспондирующий счет2: фирма &1 внутр. код счета &2", p-host-code, p-cor-acc1), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc1":U  else v-ret-mess).
  end.
/*  if buf_fin-code-cor-acc.code-value <> p-cor-acc1-value then do:                                                                                                                                                                          */
/*    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код корреспондирующего счета2 и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc1, p-cor-acc1-value), output v-ret-mess ).*/
/*    undo, return error (if p-silent = no then  "cor-acc1-value":U  else v-ret-mess).                                                                                                                                                       */
/*  end.                                                                                                                                                                                                                                     */
  if buf_fin-code-cor-acc.status_ <> integer({&current-status-int}) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус корр счета2: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cor-acc1, p-cor-acc1-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cor-acc1-value":U else v-ret-mess).
  end.
end.
if p-AN-UCHET-CODE <> 0 then do:
  find first buf_fin-code-AN-UCHET no-lock where
            buf_fin-code-an-uchet.host-code = p-host-code
        AND buf_fin-code-an-uchet.fin-code = p-an-uchet-code no-error .
  if not available buf_fin-code-an-uchet then do:
    run err-mess in this-procedure (substitute("Не найден счет аналитического учета: фирма &1 внутр. код счета &2", p-host-code, p-an-uchet-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-code":U  else v-ret-mess).
  end.
  if buf_fin-code-an-uchet.code-value <> p-an-uchet-value then do:
    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код счета ан. учета и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-an-uchet-code, p-an-uchet-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U  else v-ret-mess).
  end.
  if buf_fin-code-an-uchet.status_ <> integer({&current-status-int}) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус кода ан. учета: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-an-uchet-code, p-an-uchet-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U else v-ret-mess).
  end.
end.
if p-cel-nazn-code <> 0 then do:
  find first buf_fin-code-cel-nazn no-lock where
            buf_fin-code-cel-nazn.host-code = p-host-code
        AND buf_fin-code-cel-nazn.fin-code = p-cel-nazn-code no-error .
  if not available buf_fin-code-cel-nazn then do:
    run err-mess in this-procedure (substitute("Не найден счет целевого назначения: фирма &1 внутр. код счета &2", p-host-code, p-cel-nazn-code), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cel-nazn":U  else v-ret-mess).
  end.
  if buf_fin-code-cel-nazn.code-value <> p-cel-nazn-value then do:
    run err-mess in this-procedure (substitute("Не соответствуют друг другу внутр код счета цел. назн. и его значение: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cel-nazn-code, p-cel-nazn-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "cel-nazn-value":U  else v-ret-mess).
  end.
  if buf_fin-code-cel-nazn.status_ <> integer({&current-status-int}) then do:
    run err-mess in this-procedure (substitute("Недопустимый статус кода целевого назначения: фирма &1 внутр. код счета &2 значение &3", p-host-code, p-cel-nazn-code, p-cel-nazn-value), output v-ret-mess ).
    undo, return error (if p-silent = no then  "an-uchet-value":U else v-ret-mess).
  end.
end.
if p-sum-doc = 0 then do:
  if p-fin-doc-type = {&expense-payoff}
  or p-fin-doc-type = {&income-payoff} then do:
    for each buf_fin-connect no-lock where
            buf_fin-connect.host-code = p-host-code
        AND buf_fin-connect.fin-doc-code = p-fin-doc-code:
      assign
      accum-rubl = accum-rubl   + buf_fin-connect.sum-rubl
      accum-base = accum-base   + buf_fin-connect.sum-base
      accum-doc  = accum-doc    + buf_fin-connect.sum-doc
      accum-contr = accum-contr + buf_fin-connect.sum-contr
      .
    end.
    if accum-rubl <> 0
    OR accum-base <> 0
    OR accum-doc <> 0
    OR accum-contr <> 0 then do:
      run err-mess in this-procedure ("Сумма по документу равна 0", output v-ret-mess ).
    end.
  end.
  else do:
    run err-mess in this-procedure ("Сумма по документу равна 0", output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U else v-ret-mess).
  end.
end.
if round(p-sum-contr,2) < round(p-con-sum-contr,2) then do:
  run err-mess in this-procedure ("Сумма по документу (вал.дог.) " + string(p-sum-contr) + " не может быть меньше суммы (вал.дог.) " + string(p-con-sum-contr) + " имеющихcя связей с ФО", output v-ret-mess ).
  /*формулировка Кочеткова*/
  undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
end.
if l-shift-on
and lookup(p-fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
and (p-doc-author = {&manual} or p-doc-author = {&auto})
/*and v-cash-book = integer({&cash-book-object})*/
then do:
   /*проверим корректно ли заполнена смена*/
  v-flag-shift = yes.
  define variable v-fin-doc-shift-name-check as character no-undo .
 if p-shift-date = ?
 or p-shift-num < {&min-shift-num}
 or p-shift-num > {&max-shift-num}
 then do:
    run err-mess in this-procedure ( substitute("Неверная сменная дата &1 или порядок смены &2"
                                     ,p-shift-date
                                     ,p-shift-num), output v-ret-mess).
    /*формулировка Кочеткова*/
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).

 end.
 define variable v-dop as character no-undo .
 { str/shiftnam.i
   p-obj-type
   p-obj-code
   p-shift-date
   p-shift-num
   v-fin-doc-shift-name-check
   v-dop
  no-error
  }
  if error-status:error then do:
    run err-mess in this-procedure (substitute( "Ошибка при проверке сменной даты&1&2&1&3"
                                      ,{&new-line}, error-status :get-message (1), return-value  )
                                      , output v-ret-mess ).
    undo, return error (if p-silent = no then  "shift-date":U  else v-ret-mess).
  end.
end.
if not (p-mode = {&update}
       and
       v-author <> '') then do:
  for each tt0-fin-doc-tax no-lock where
          tt0-fin-doc-tax.host-code = p-host-code
      AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code:
    assign
    v-acc = v-acc + tt0-fin-doc-tax.sum-line-doc
    .
  end.
  if abs(v-acc - p-sum-doc) > 0.01 then do:
    run err-mess in this-procedure ("Сумма по документу " + string(p-sum-doc) + " не равна сумме строк по исчислению налогов " +  string(v-acc), output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
  end.
end.

if not (p-mode = {&update}
       and
       v-author <> '')
and p-save-payment
       then do:
  v-acc = 0.
  for each tt0-payment no-lock where
          tt0-payment.host-code = p-host-code
      AND tt0-payment.source-type = {&pmnt-fin-doc}
      AND tt0-payment.source-ref = string(p-fin-doc-code):
    if not (tt0-payment.payer-type = p-payer-type
            and
            tt0-payment.payer-code = p-payer-code) then do:
    run err-mess in this-procedure ( substitute("Привязка к ДК сделана для &1&2,&3" +
                                                "а ПЛАТЕЛЬЩИК для платежа  &4&5"
                                                , tt0-payment.payer-type
                                                , tt0-payment.payer-code
                                                , {&new-line}
                                                , p-payer-type
                                                , p-payer-code
                                                )
                                          , output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
    end.
    assign
    v-acc = v-acc + tt0-payment.tot-cli
    .
    v-found = yes.
  end.
  if v-found = yes
  and not (p-fin-ext-doc-type = {&FDEDT_income_cash}
           or
           p-fin-ext-doc-type = {&FDEDT_income_cashless}
           or
           p-fin-ext-doc-type = {&FDEDT_income_payoff}
           ) then do:
    run err-mess in this-procedure ( substitute("Не предусмотрена привязка к ДК для платежей типа &1"
                                                , p-fin-ext-doc-type)
                                          , output v-ret-mess ).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.

  if v-found = yes
  and v-acc <> p-sum-doc then do:
    run err-mess in this-procedure ("Сумма по документу не равна сумме строк по ДК", output v-ret-mess ).
    undo, return error (if p-silent = no then  "sum-doc":U  else v-ret-mess).
  end.
end.


&scop prfx p-
/*здесь проверим все документы отдельно по типам*/
CASE p-fin-doc-type:
  when {&income-cash} then do:
    run ref/findoc01.p (
                    input p-mode
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when {&income-cashless} then do:
    run ref/findoc03.p (
                    input p-mode + {&delim-par} + v-author
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.

  end.
  when {&expense-cash} then do:
    run ref/findoc02.p (
                    input p-mode
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.

  end.
  when {&expense-cashless} then do:
    run ref/findoc04.p (
                    input p-mode + {&delim-par} + v-author
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.

  end.
  when {&income-payoff} then do:
    run ref/findoc05.p (
                    input p-mode
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
  when {&expense-payoff} then do:
    run ref/findoc06.p (
                    input p-mode
                    ,input "":U /*p-close-mode*/
                    {&all-fin-doc-params-doc-status-transfer}
                    {&all-fin-doc-params-doc-status-transfer-2}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.

  end.
  otherwise do:
    run err-mess in this-procedure (substitute("Неверный тип платежа &1", p-fin-doc-type), output v-ret-mess ).
    undo, return error (if p-silent = no then  "fin-doc-type":U  else v-ret-mess).
  end.
END CASE.
if error-status:error then do:
  run err-mess in this-procedure (substitute("Ошибка при проверке валидности платежа: &1", error-status:get-message(1) ), output v-ret-mess).
  undo, return error (if p-silent = no then  '':U  else v-ret-mess).
end.
if not v-correct then do:
  run err-mess in this-procedure (substitute("Неверные реквизиты платежа &1", v-err-mess), output v-ret-mess).
  undo, return error (if p-silent = no then  return-value  else v-ret-mess).
end.
if lookup(p-fin-ext-doc-type, {&fin-ext-doc-types}) = 0 then do:
  run err-mess in this-procedure (substitute("Неверный расширенный тип платежа &1", p-fin-ext-doc-type), output v-ret-mess ).
  undo, return error (if p-silent = no then  "fin-ext-doc-type":U  else v-ret-mess).
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.fin-doc.
    assign
    ub.fin-doc.host-code = p-host-code
    ub.fin-doc.fin-doc-code = p-fin-doc-code
    ub.fin-doc.status_ = {&fin-new}
    p-doc-rec = recid(ub.fin-doc)
    .
    /*при создании платежа проставим cash-book-place  - auto сюда не должны попадать*/
/*    if v-obj-db-num = g#db-num then do:                     */
/*      if v-cash-book = integer({&cash-book-object}) then do:*/
        assign
        v-cash-book-place = buf_clients-obj.obj-type + string(buf_clients-obj.obj-code, "99999")
        .
/*      end.*/
/*    end.  */
  end.
  else do:
    FIND FIRST ub.fin-doc where
              recid(ub.fin-doc) = p-doc-rec No-ERROR.
    if not available ub.fin-doc then do:
      run err-mess in this-procedure (substitute("Не найдена запись ПЛАТЕЖА - p-doc-rec &1", p-doc-rec), output v-ret-mess).
      undo, return error (if p-silent = no then  '':u  else v-ret-mess).
    end.
    if ub.fin-doc.host-code <> p-host-code
    OR ub.fin-doc.fin-doc-code <> p-fin-doc-code
    OR ub.fin-doc.fin-doc-type <> p-fin-doc-type
    then do:
      run err-mess in this-procedure (substitute("Для уже имеющейся записи нельзя изменить&1" +
                               "код фирмы, внутренний код платежа, тип платежа&1"
                               , {&new-line}), output v-ret-mess).
      undo, return error (if p-silent = no then  '':U  else v-ret-mess).
    end.
    v-cash-book-place = ub.fin-doc.trn-doc-code.
    if not (ub.fin-doc.obj-type = p-obj-type
           and
           ub.fin-doc.obj-code = p-obj-code
           )
    and ub.fin-doc.user-db-num-doc = g#db-num
    then do:

      { gbl/fautoobj.i p-host-code p-fin-doc-code v-is-auto-obj }
      if not v-is-auto-obj then do:
         /*надо перезаполнить*/
/*        if v-obj-db-num = g#db-num then do:                                                        */
/*          /*только там может быть не пусто v-cash-book-place */                                    */
/*          { gbl/cashbook.i buf_clients-obj.obj-type buf_clients-obj.obj-code v-cash-book no-error }*/
/*                                                                                                   */
/*          if v-cash-book = integer({&cash-book-object}) then do:                                   */
/*            assign                                                                                 */
/*            v-cash-book-place = p-obj-type + string(p-obj-code, "99999")                           */
/*            .                                                                                      */
/*          end.                                                                                     */
/*          else do:                                                                                 */
/*            assign                                                                                 */
/*            v-cash-book-place = ''.                                                                */
/*          end.                                                                                     */
/*        end.                                                                                       */
/*        else do:                                                                                   */
/*          assign                                                                                   */
/*          v-cash-book-place = ''.                                                                  */
/*        end.                                                                                       */
        assign
        v-cash-book-place = p-obj-type + string(p-obj-code, "99999")
        .
      end. /*if not v-is-auto-obj then do:*/
      else do:
        assign v-cash-book-place = "".
      end.
    end. /*if not (ub.fin-doc.obj-type = p-obj-type*/
    if ub.fin-doc.status_ <> {&fin-new}
    then do:
      if  v-author = ''
      then do:
        if
        ub.fin-doc.base-rate           <> p-base-rate
        or
        ub.fin-doc.base-scale          <> p-base-scale
        or
        ub.fin-doc.contract-curr       <> p-contract-curr
        or
        ub.fin-doc.contract-rate       <> p-contract-rate
        or
        ub.fin-doc.contract-scale      <> p-contract-scale
        or
        ub.fin-doc.enclosure           <> p-enclosure
        or
        ub.fin-doc.exch-rate           <> p-exch-rate
        or
        ub.fin-doc.exch-scale          <> p-exch-scale
        or
        ub.fin-doc.f104                <> p-f104
        or
        ub.fin-doc.f105                <> p-f105
        or
        ub.fin-doc.f106                <> p-f106
        or
        ub.fin-doc.f107                <> p-f107
        or
        ub.fin-doc.f108                <> p-f108
        or
        ub.fin-doc.f109                <> p-f109
        or
        ub.fin-doc.f110                <> p-f110
        or
        ub.fin-doc.f22                 <> p-f22
        or
        ub.fin-doc.f23                 <> p-f23
        or
        ub.fin-doc.fin-doc-type        <> p-fin-doc-type
        or
        ub.fin-doc.including           <> p-including
        or
        ub.fin-doc.nazn-pl             <> p-nazn-pl
        or
        ub.fin-doc.naznach-plat        <> p-naznach-plat
        or
        ub.fin-doc.ocher-pl            <> p-ocher-pl
        or
        ub.fin-doc.payer-bank-name     <> p-payer-bank-name
        or
        ub.fin-doc.payer-bank-city     <> p-payer-bank-city
        or
        ub.fin-doc.payer-bik           <> p-payer-bik
        or
        ub.fin-doc.payer-c-schet       <> p-payer-c-schet
        or
        ub.fin-doc.payer-code-schet    <> p-payer-code-schet
        or
        ub.fin-doc.payer-inn           <> p-payer-inn
        or
        ub.fin-doc.payer-kpp           <> p-payer-kpp
        or
        ub.fin-doc.payer-name          <> p-payer-name
        or
        ub.fin-doc.payer-okpo          <> p-payer-okpo
        or
        ub.fin-doc.payer-passport   <> p-payer-passport
        or
        ub.fin-doc.payer-r-schet       <> p-payer-r-schet
        or
        ub.fin-doc.receiver-bank-name  <> p-receiver-bank-name
        or
        ub.fin-doc.receiver-bank-city  <> p-receiver-bank-city
        or
        ub.fin-doc.receiver-bik        <> p-receiver-bik
        or
        ub.fin-doc.receiver-c-schet    <> p-receiver-c-schet
        or
        ub.fin-doc.receiver-code-schet <> p-receiver-code-schet
        or
        ub.fin-doc.receiver-inn        <> p-receiver-inn
        or
        ub.fin-doc.receiver-kpp        <> p-receiver-kpp
        or
        ub.fin-doc.receiver-name       <> p-receiver-name
        or
        ub.fin-doc.receiver-okpo       <> p-receiver-okpo
        or
        ub.fin-doc.receiver-passport   <> p-receiver-passport
        or
        ub.fin-doc.receiver-r-schet    <> p-receiver-r-schet
        or
        ub.fin-doc.payer-sign1         <> p-payer-sign1
        or
        ub.fin-doc.payer-sign2         <> p-payer-sign2
        or
        ub.fin-doc.payer-sign3         <> p-payer-sign3
        or
        ub.fin-doc.receiver-sign1         <> p-receiver-sign1
        or
        ub.fin-doc.receiver-sign2         <> p-receiver-sign2
        or
        ub.fin-doc.receiver-sign3         <> p-receiver-sign3
        or
        ub.fin-doc.srok-pl             <> p-srok-pl
        or
        ub.fin-doc.stat-pl             <> p-stat-pl
        or
        ub.fin-doc.str-podr-code       <> p-str-podr-code
        or
        ub.fin-doc.str-podr-type       <> p-str-podr-type
        or
        ub.fin-doc.str-podr-name       <> p-str-podr-name
        or
        ub.fin-doc.sum-base            <> p-sum-base
        or
        ub.fin-doc.sum-doc             <> p-sum-doc
        or
        ub.fin-doc.sum-rubl            <> p-sum-rubl
        or
        ub.fin-doc.vid-opl             <> p-vid-opl
        or
        ub.fin-doc.vid-plat            <> p-vid-plat
        or
        not (ub.fin-doc.obj-type       = p-obj-type
             and
             ub.fin-doc.obj-code       = p-obj-code
             and
             (ub.fin-doc.shift-flag = integer({&fin-flag-shift})
              or
              not v-flag-shift
             )
             )
        then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "можно менять только примечания, коды аналитического учета, объект(для несменных платежей) и НОМЕР&2"
                                  ,{&fin-new}
                                  , {&new-line})
                        , output v-ret-mess).

          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
      end. /*if  v-author <> 'cl-bank' then do:*/
      if
      ub.fin-doc.sum-doc             <> p-sum-doc
      or
      ub.fin-doc.curr-code           <> p-curr-code
      or
      ub.fin-doc.payer-type          <> p-payer-type
      or
      ub.fin-doc.payer-code          <> p-payer-code
      or
      ub.fin-doc.receiver-code       <> p-receiver-code
      or
      ub.fin-doc.receiver-type       <> p-receiver-type
      then do:
        if v-author = '':U then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "можно менять только примечания, коды аналитического учета, объект и НОМЕР&2"
                                  ,{&fin-new}
                                  , {&new-line})
                        , output v-ret-mess).
          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
        if v-author <> '' then do:
          run err-mess in this-procedure (substitute("Для ПЛАТЕЖА в статусе не &1&2" +
                                  "НЕЛЬЗЯ менять сумму платежа, валюту платежа, ПЛАТЕЛЬЩИКА и ПОЛУЧАТЕЛЯ&2"
                                  ,{&fin-new}
                                  , {&new-line})
                        , output v-ret-mess).
          undo, return error (if p-silent = no then  '':U  else v-ret-mess).
        end.
      end.
    end.
  end.

/*  define variable v-ok as logical no-undo .                                                                                        */
/*  define variable v-out-mess as character no-undo .                                                                                */
/*  { str/finchkdb.i                                                                                                                 */
/*    p-host-code                                                                                                                    */
/*    p-fin-doc-code                                                                                                                 */
/*    p-obj-type                                                                                                                     */
/*    p-obj-code                                                                                                                     */
/*    p-fin-ext-doc-type                                                                                                             */
/*    v-cash-book-place                                                                                                              */
/*    "p-doc-author = 'fin-ob'"                                                                                                      */
/*    v-ok                                                                                                                           */
/*    v-out-mess                                                                                                                     */
/*    no-error }                                                                                                                     */
/*  if error-status:error then do:                                                                                                   */
/*    run err-mess in this-procedure ( substitute("Ошибка при проверке возможности сохранения документа в данной БД (&1)" , v-db-num)*/
/*                                    , output v-ret-mess).                                                                          */
/*    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).                                                       */
/*  end.                                                                                                                             */
/*  if not v-ok then do:                                                                                                             */
/*    run err-mess in this-procedure ( v-out-mess, output v-ret-mess).                                                               */
/*    undo, return error (if p-silent = no then "obj-code":U else v-ret-mess).                                                       */
/*  end.                                                                                                                             */

  assign
  ub.fin-doc.an-uchet-code       = p-an-uchet-code
  ub.fin-doc.an-uchet-value      = (if p-an-uchet-code <> 0 then p-an-uchet-value else "":U)
  ub.fin-doc.base-rate           = p-base-rate
  ub.fin-doc.base-scale          = p-base-scale
  ub.fin-doc.cel-nazn-code       = p-cel-nazn-code
  ub.fin-doc.cel-nazn-value      = (if p-cel-nazn-code <> 0 then p-cel-nazn-value else "":U)
  ub.fin-doc.contract-code       = p-contract-code
  ub.fin-doc.contract-curr       = p-contract-curr
  ub.fin-doc.contract-rate       = p-contract-rate
  ub.fin-doc.contract-scale      = p-contract-scale
  ub.fin-doc.cor-acc             = p-cor-acc
  ub.fin-doc.cor-acc-value       = (if p-cor-acc <> 0 then p-cor-acc-value else "":U)
  ub.fin-doc.cor-acc1            = p-cor-acc1
  ub.fin-doc.cor-acc1-value      = (if p-cor-acc1 <> 0 then p-cor-acc1-value else "":U)
  ub.fin-doc.curr-code           = p-curr-code
  ub.fin-doc.doc-date            = p-doc-date
  ub.fin-doc.enclosure           = p-enclosure
  ub.fin-doc.exch-rate           = p-exch-rate
  ub.fin-doc.exch-scale          = p-exch-scale
  ub.fin-doc.f104                = p-f104
  ub.fin-doc.f105                = p-f105
  ub.fin-doc.f106                = p-f106
  ub.fin-doc.f107                = p-f107
  ub.fin-doc.f108                = p-f108
  ub.fin-doc.f109                = p-f109
  ub.fin-doc.f110                = p-f110
  ub.fin-doc.f22                 = p-f22
  ub.fin-doc.f23                 = p-f23
  ub.fin-doc.fin-doc-type        = p-fin-doc-type
  ub.fin-doc.fin-ext-doc-type    = p-fin-ext-doc-type
  ub.fin-doc.in-doc-code         = p-in-doc-code
  ub.fin-doc.in-host-code        = p-in-host-code
  ub.fin-doc.including           = p-including
  ub.fin-doc.nazn-pl             = p-nazn-pl
  ub.fin-doc.naznach-plat        = p-naznach-plat
  ub.fin-doc.obj-type            = p-obj-type
  ub.fin-doc.obj-code            = p-obj-code
  ub.fin-doc.ocher-pl            = p-ocher-pl
  ub.fin-doc.out-doc-code        = p-out-doc-code
  ub.fin-doc.out-host-code       = p-out-host-code
  ub.fin-doc.payer-bank-name     = p-payer-bank-name
  ub.fin-doc.payer-bank-city     = p-payer-bank-city
  ub.fin-doc.payer-bik           = p-payer-bik
  ub.fin-doc.payer-c-schet       = p-payer-c-schet
  ub.fin-doc.payer-code          = p-payer-code
  ub.fin-doc.payer-code-schet    = p-payer-code-schet
  ub.fin-doc.payer-inn           = p-payer-inn
  ub.fin-doc.payer-kpp           = p-payer-kpp
  ub.fin-doc.payer-name          = p-payer-name
  ub.fin-doc.payer-okpo          = p-payer-okpo
  ub.fin-doc.payer-dop1          = p-payer-dop1
  ub.fin-doc.payer-dop2          = p-payer-dop2
  ub.fin-doc.payer-passport      = p-payer-passport
  ub.fin-doc.payer-r-schet       = p-payer-r-schet
  ub.fin-doc.payer-type          = p-payer-type
  ub.fin-doc.prn-doc-code        = p-prn-doc-code
  ub.fin-doc.PS                  = p-PS
  ub.fin-doc.receiver-bank-name  = p-receiver-bank-name
  ub.fin-doc.receiver-bank-city  = p-receiver-bank-city
  ub.fin-doc.receiver-bik        = p-receiver-bik
  ub.fin-doc.receiver-c-schet    = p-receiver-c-schet
  ub.fin-doc.receiver-code       = p-receiver-code
  ub.fin-doc.receiver-code-schet = p-receiver-code-schet
  ub.fin-doc.receiver-inn        = p-receiver-inn
  ub.fin-doc.receiver-kpp        = p-receiver-kpp
  ub.fin-doc.receiver-name       = p-receiver-name
  ub.fin-doc.receiver-okpo       = p-receiver-okpo
  ub.fin-doc.receiver-dop1       = p-receiver-dop1
  ub.fin-doc.receiver-dop2       = p-receiver-dop2
  ub.fin-doc.receiver-passport   = p-receiver-passport
  ub.fin-doc.receiver-r-schet    = p-receiver-r-schet
  ub.fin-doc.receiver-type       = p-receiver-type
  ub.fin-doc.payer-sign1         = p-payer-sign1
  ub.fin-doc.payer-sign2         = p-payer-sign2
  ub.fin-doc.payer-sign3         = p-payer-sign3
  ub.fin-doc.receiver-sign1      = p-receiver-sign1
  ub.fin-doc.receiver-sign2      = p-receiver-sign2
  ub.fin-doc.receiver-sign3      = p-receiver-sign3
  ub.fin-doc.srok-pl             = p-srok-pl
  ub.fin-doc.stat-pl             = p-stat-pl
  ub.fin-doc.str-podr-code       = p-str-podr-code
  ub.fin-doc.str-podr-type       = p-str-podr-type
  ub.fin-doc.str-podr-name       = p-str-podr-name
  ub.fin-doc.sum-base            = p-sum-base
  ub.fin-doc.sum-doc             = p-sum-doc
  ub.fin-doc.sum-rubl            = p-sum-rubl
  ub.fin-doc.sum-contr           = p-sum-contr
  ub.fin-doc.trn-doc-code        = v-cash-book-place
  ub.fin-doc.vid-opl             = p-vid-opl
  ub.fin-doc.vid-plat            = p-vid-plat
  ub.fin-doc.user-db-num-doc     = g#db-num
  ub.fin-doc.user-name-doc       = g#userid
  ub.fin-doc.CashBookId          = p-cashbookid 
  ub.fin-doc.doc-author          = (if v-author = '':U
                                    and p-doc-author <> {&manual}
                                    then ub.fin-doc.doc-author
                                    else p-doc-author
                                    )
  ub.fin-doc.shift-flag =  (if l-shift-on
                                  and lookup(ub.fin-doc.fin-ext-doc-type, {&fin-ext-doc-cash-types}) > 0
                                  and (ub.fin-doc.doc-author = {&manual} or ub.fin-doc.doc-author = {&auto})
                                  then integer({&fin-flag-shift})
                                  else 0)
  ub.fin-doc.shift-date  = p-shift-date
  ub.fin-doc.shift-num   = p-shift-num
  ub.fin-doc.shift-name  = p-shift-name
  .

  if ub.fin-doc.con-stat > 0 then do:
    if ub.fin-doc.con-stat = 1 then do:
      if ub.fin-doc.sum-contr <= ub.fin-doc.con-sum-contr then assign ub.fin-doc.con-stat = 2 .
    end.
    else do:
      if ub.fin-doc.sum-contr > ub.fin-doc.con-sum-contr then assign ub.fin-doc.con-stat = 1 .
    end.
  end.
  /* для генерации счетов-фактур */
  if available buf_contract then do:
    if (buf_contract.gen-factur = 3 or
        buf_contract.gen-factur = 13 or
        buf_contract.gen-factur = 103 or
        buf_contract.gen-factur = 113) then
      assign  ub.fin-doc.need-factur = 1 .
  end.

  release ub.fin-doc no-error.
  if error-status:error then do:
   run err-mess in this-procedure (substitute("Ошибка при сохранении записи ПЛАТЕЖА &1: &2", ERROR-STATUS:GET-message(1), return-value ), output v-ret-mess).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.
  if not (p-mode = {&update}
         and
         v-author <> '') then do:
    for each ub.fin-doc-tax where
            ub.fin-doc-tax.host-code = p-host-code
        AND ub.fin-doc-tax.fin-doc-code = p-fin-doc-code:
      find first tt0-fin-doc-tax no-lock where
                tt0-fin-doc-tax.host-code = p-host-code
            AND tt0-fin-doc-tax.fin-doc-code = p-fin-doc-code
            AND tt0-fin-doc-tax.line-num = ub.fin-doc-tax.line-num no-error .
      if not available tt0-fin-doc-tax then do:
        delete ub.fin-doc-tax.
      end.
    end.
  for each tt0-fin-doc-tax :
      find first ub.fin-doc-tax where
                ub.fin-doc-tax.host-code = p-host-code
            AND ub.fin-doc-tax.fin-doc-code = p-fin-doc-code
            AND ub.fin-doc-tax.line-num   = tt0-fin-doc-tax.line-num
            no-error .
      if not available ub.fin-doc-tax then do:
        create ub.fin-doc-tax.
        assign
        ub.fin-doc-tax.host-code = p-host-code
        ub.fin-doc-tax.fin-doc-code = p-fin-doc-code
        ub.fin-doc-tax.line-num = tt0-fin-doc-tax.line-num
        .
      end.
      buffer-copy tt0-fin-doc-tax except host-code fin-doc-code line-num
      to ub.fin-doc-tax.
      run recalc-tax in this-procedure (buffer ub.fin-doc-tax
                                      , p-curr-code
                                      , p-contract-curr
                                      , p-base-rate
                                      , p-base-scale
                                      , p-exch-rate
                                      , p-exch-scale
                                      , p-contract-rate
                                      , p-contract-scale
                                      ).
    end.
    for each tt0-fin-doc-attr :
      find first ub.fin-doc-attr where
                ub.fin-doc-attr.host-code = p-host-code
            AND ub.fin-doc-attr.fin-doc-code = p-fin-doc-code
            AND ub.fin-doc-attr.attr-code   = tt0-fin-doc-attr.attr-code
            no-error .
      if not available ub.fin-doc-attr then do:
        create ub.fin-doc-attr.
      end.
      buffer-copy tt0-fin-doc-attr to ub.fin-doc-attr.
    end.

    define variable v-cmp as logical no-undo .
    if  p-save-payment then do:
      for each ub.payment where
              ub.payment.host-code = p-host-code
          AND ub.payment.source-type = {&pmnt-fin-doc}
          and ub.payment.source-ref = string(p-fin-doc-code)
    on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-workfile )
    on endkey undo , return error substitute( "&1. endkey", vss-workfile )
    :
        find first tt0-payment no-lock where
                  tt0-payment.host-code = p-host-code
              AND tt0-payment.source-type = ub.payment.source-type
              AND tt0-payment.source-ref = ub.payment.source-ref
              and tt0-payment.d-card = ub.payment.d-card  no-error .
        if not available tt0-payment then do:
          delete ub.payment no-error.
          if error-status:error then do:
            run err-mess in this-procedure (substitute("Ошибка при удалении привязки платежа к ДК &4&1&2&1&3"
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    , tt0-payment.d-card
                                    )
                          , output v-ret-mess).
            undo, return error (if p-silent = no then  '':U  else v-ret-mess).
          end.
        end.
      end.
      for each tt0-payment
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        v-cmp = yes.
        find first ub.payment where
                  ub.payment.host-code = p-host-code
              AND ub.payment.source-type = {&pmnt-fin-doc}
              AND ub.payment.source-ref = string(p-fin-doc-code)
              and ub.payment.d-card = tt0-payment.d-card
              no-error .
        if not available ub.payment then do:
          if v-pmnt-code = '':U then do:
            find first buf0_payment no-lock where buf0_payment.host-code = p-host-code
                AND buf0_payment.source-type = {&pmnt-fin-doc}
                AND buf0_payment.source-ref = string(p-fin-doc-code) no-error.
          if available buf0_payment then do:
            assign
            v-pmnt-code = entry(1, buf0_payment.pmnt-code, "_").
          end.
          end.
          assign
          v-full-pmnt-code  = substitute("&1_&2", v-pmnt-code, entry(2, tt0-payment.pmnt-code, "_"))
          tt0-payment.pmnt-code = v-full-pmnt-code
          .
          v-cmp = no.
        end.
        else do:
          buffer-compare tt0-payment
          except pmnt-code to ub.payment
          case-sensitive
          save result in v-cmp.
        end.
        if not v-cmp then do:
          run ref/payment1.p (
                                input (if available ub.payment then {&update} else {&add-def})
                              ,input p-silent
                              ,input-output tt0-payment.pmnt-code
                              ,input tt0-payment.cli-type
                              ,input tt0-payment.cli-code
                              ,input p-payer-type
                              ,input p-payer-code
                              ,input tt0-payment.host-code
                              ,input tt0-payment.tot-cli
                              ,input (tt0-payment.tot-cli * p-exch-rate / p-exch-scale) /  (p-base-rate / p-base-scale)
                              ,input (tt0-payment.tot-cli * p-exch-rate / p-exch-scale)
                              ,input p-doc-date /*p-exch-date*/
                              ,input p-curr-code
                              ,input tt0-payment.exch-rate
                              ,input tt0-payment.exch-scale
                              ,input tt0-payment.base-rate
                              ,input tt0-payment.base-scale
                              ,input p-pay-date
                              ,input ? /*p-fact-date*/
                              ,input tt0-payment.source-type
                              ,input tt0-payment.source-ref
                              ,input tt0-payment.d-card
                              ,input tt0-payment.pay-code
                              ,input {&expected}
                              ,input tt0-payment.PS
                              ,INPUT g#userid /*creid*/
                              ,INPUT '':U /*closid*/
                              ) no-error .
          if error-status:error then do:
            run err-mess in this-procedure (substitute("Ошибка при создании привязки платежа к ДК &4&1&2&1&3"
                                    ,{&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    , tt0-payment.d-card
                                    )
                          , output v-ret-mess).
            undo, return error (if p-silent = no then  '':U  else v-ret-mess).
          end.
        end. /*if not v-cmp*/
      end. /*for each tt0-payment*/
    end. /*if  p-save-payment then do:*/
  end. /*if v-author = ''*/
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("ПЛАТЕЖ &1: фирма: &2 N: &3,&4 вн. № &5&4&6"
                            , p-fin-doc-type
                            , p-host-code
                            , p-prn-doc-code
                            , {&new-line}
                            , p-fin-doc-code
                            , p-mess
                            ).

  CASE p-silent:
    when yes then do:
      p-ret-mess = substitute("ПЛАТЕЖ &1: фирма: &2 N: &3 Вн № &4&5&6"
                              , p-fin-doc-type
                              , p-host-code
                              , p-prn-doc-code
                              , p-fin-doc-code
                              , {&new-line}
                              , p-mess
                              ).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.

procedure recalc-tax :
define parameter buffer buf_fin-doc-tax for ub.fin-doc-tax.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-contract-curr like ub.fin-doc.contract-curr no-undo .
define input parameter p-base-rate like ub.fin-doc.base-rate no-undo .
define input parameter p-base-scale like ub.fin-doc.base-scale no-undo .
define input parameter p-exch-rate like ub.fin-doc.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-doc.exch-scale no-undo .
define input parameter p-contract-rate like ub.fin-doc.contract-rate no-undo .
define input parameter p-contract-scale like ub.fin-doc.contract-scale no-undo .

  do
  on error undo, return error
  :
    CASE p-curr-code:
      when 0 then do:
        assign
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc / p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc / p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc / p-base-rate * p-base-scale
        .
      end. /*when buf_fin-doc-tax.curr-code = 0*/
      when v-base-code then do:
        assign
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc * p-base-rate / p-base-scale
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc * p-base-rate / p-base-scale
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc * p-base-rate / p-base-scale
        .
      end. /*when base-code*/
      otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
        assign
        buf_fin-doc-tax.sum-line-rubl = buf_fin-doc-tax.sum-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-line-base = buf_fin-doc-tax.sum-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-slt-line-rubl = buf_fin-doc-tax.sum-slt-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-slt-line-base = buf_fin-doc-tax.sum-slt-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        buf_fin-doc-tax.sum-vat-line-rubl = buf_fin-doc-tax.sum-vat-line-doc * p-exch-rate / p-exch-scale
        buf_fin-doc-tax.sum-vat-line-base = buf_fin-doc-tax.sum-vat-line-doc * (p-exch-rate / p-exch-scale)  /
        p-base-rate * p-base-scale
        .
      end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
    END CASE.

    CASE p-contract-curr:
      when p-curr-code then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-doc
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-doc
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-doc
        .
      end.
      when 0 then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-rubl
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-rubl
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-rubl
        .
      end. /*when buf_fin-doc-tax.curr-code = 0*/
      when v-base-code then do:
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-base
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-base
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-base
        .
      end. /*when base-code*/
      otherwise do: /*ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
        assign
        buf_fin-doc-tax.sum-line-contr = buf_fin-doc-tax.sum-line-rubl / ( p-contract-rate / p-contract-scale)
        buf_fin-doc-tax.sum-slt-line-contr = buf_fin-doc-tax.sum-slt-line-rubl / ( p-contract-rate / p-contract-scale)
        buf_fin-doc-tax.sum-vat-line-contr = buf_fin-doc-tax.sum-vat-line-rubl / ( p-contract-rate / p-contract-scale )
        .
      end. /*when ОПЛАТА НЕ В БАЗ ВАЛ И НЕ В Р_У_БЛЯХ*/
    END CASE.


  end.

end procedure. /* recalc-tax */