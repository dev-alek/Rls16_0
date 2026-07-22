block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности при сохранении изменений в типе кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04


*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-silent as logical no-undo .
define input parameter parobj-code like ub.cash-pay.cdpay-code no-undo .
define input parameter parobj-name like ub.cash-pay.obj-name no-undo .
define input parameter parcurr-code like ub.cash-pay.curr-code no-undo .
define input parameter parpay-code like ub.cash-pay.pay-code no-undo .
define input parameter parwth-code like ub.cash-pay.wth-code no-undo .
define input parameter parpay-limit like ub.cash-pay.pay-limit no-undo .
define input parameter parpay-card-view like ub.cash-pay.pay-card-view no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности при сохранении изменений в типе кассовых платежей".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
DEFINE VARIABLE is-wth as logical no-undo .
DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
define variable v-int as integer no-undo .
define variable ii as integer no-undo .
define variable v-mess as character no-undo .
define buffer buf_pay-type for ub.pay-type.
define buffer buf_wealth for ub.wealth.


if (parobj-code <= 0 ) OR ( parobj-code = ? ) then do:
  v-mess = "Код платежа должен быть больше 0 !".
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'cdpay-code':U).
end.
if parobj-name = ""  then do:
  v-mess = "Не определено название типа кассового платежа!".
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'obj-name':U).
end.

if  NOT can-find( FIRST ub.currency No-LOCK WHERE
                        ub.currency.curr-code = parcurr-code ) then do:
  v-mess = substitute("Неверный код валюты &1", parcurr-code).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'curr-code':U).
end.

if parpay-limit = ? then do:
  v-mess = "Лимит для типа кассового платежа не может иметь неопределенное значение !".
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'pay-limit':U).
end.

find first buf_pay-type NO-LOCK where
           buf_pay-type.obj-code = parpay-code NO-ERROR.
if not avail buf_pay-type then do:
  v-mess = substitute( "Неверный вид оплаты &1", parpay-code).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'pay-code':U).
end.

{ gbl/conf-rd.i
"'is-wth'"
0
"''"
0
"''"
"''"
"''"
yes
conf-par
par-type
no-error
}
IF not error-status:error then
assign
is-wth = (conf-par = "yes":U).


if is-wth
and parwth-code > 0 then do:
  find first buf_wealth NO-LOCK where
             buf_wealth.wth-code = parwth-code NO-ERROR.
  if not avail buf_wealth then do:
    v-mess = substitute("Неверный код МЦ &1", parwth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if buf_wealth.is-money
  and buf_wealth.curr-code <> parcurr-code then do:
    v-mess = substitute("Не совпадают валюты МЦ &1 (код валюты &2) и типа кассового платежа &3 (код валюты &4)!"
                ,parwth-code
                ,buf_wealth.curr-code
                ,parobj-code
                ,parcurr-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if not (buf_wealth.is-money = yes
         or buf_wealth.is-ser = 1) then do:
    v-mess = substitute("МЦ с кодом &1 не имеет ДЕНЕЖНОГО ЭКВИВАЛЕНТА и не является СЕРИЙНОЙ!"
                ,buf_wealth.wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if parobj-code = 1
  and buf_wealth.get-qnty-method <> {&wth-qnty-sum}
  then do:
  &scop wth-qnty-method-code   buf_wealth.get-qnty-method
    v-mess = substitute("Тип кассового платежа с кодом 1 не может быть связан с МЦ с методом определения кол-ва МЦ = &1"
                         ,{&wth-qnty-method-name}).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
end.

if parpay-card-view <> "":u then do:
  do ii = 1 to num-entries(parpay-card-view):
    assign
    v-int = integer(entry(ii, parpay-card-view))
    no-error
    .
    if error-status:error
    or entry(ii, parpay-card-view) = "":U then do:
      v-mess =  "Неверное значение поля <СПИСОК ПРЕФИКСОВ НОМЕРОВ ПЛАТЕЖНЫХ КАРТ ДЛЯ ПРОСМОТРА>".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'pay-card-view':U).
    end.
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Тип касс.платежа с кодом &1 и кодом валюты &2&3&4"
                         , parobj-code
                         , parcurr-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.