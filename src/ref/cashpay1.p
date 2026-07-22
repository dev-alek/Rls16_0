block-level on error undo, throw.
/*

$Revision: b9071463af06, 3465, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:34 $
$Workfile: cashpay1.p $
$Archive: ref/cashpay1.p $

Сохранение изменений в типе кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/06
Author: Bakhtadze Natalya
Creation date: 03/22/06

*/

/*

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-silent as logical no-undo .
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter parcdpay-code  like ub.cash-pay.cdpay-code  no-undo .
define input parameter parobj-name  like ub.cash-pay.obj-name  no-undo .
define input parameter parcurr-code like ub.cash-pay.curr-code no-undo .
define input parameter parpay-code  like ub.cash-pay.pay-code  no-undo .
define input parameter parwth-code  like ub.cash-pay.wth-code  no-undo .
define input parameter parpay-limit like ub.cash-pay.pay-limit no-undo .
define input parameter paris-cash   like ub.cash-pay.is-cash   no-undo .
define input parameter par-atr1     like ub.cash-pay.atr1      no-undo .
define input parameter par-atr2     like ub.cash-pay.atr2      no-undo .
define input parameter par-atr4     like ub.cash-pay.atr4      no-undo .
define input parameter par-atr8     like ub.cash-pay.atr8      no-undo .
define input parameter par-atr16    like ub.cash-pay.atr16     no-undo .
define input parameter par-atr32    like ub.cash-pay.atr32     no-undo .
define input parameter par-atr64    like ub.cash-pay.atr64     no-undo .
define input parameter par-atr128    like ub.cash-pay.atr128     no-undo .
define input parameter parpay-card-view like ub.cash-pay.pay-card-view no-undo .
define input parameter par-is-advance    like ub.cash-pay.is-advance     no-undo .
define input parameter par-is-credit     like ub.cash-pay.is-credit      no-undo .
define input parameter par-is-credit-card like ub.cash-pay.is-credit-card no-undo .
define input parameter par-is-debet-card like ub.cash-pay.is-debet-card no-undo .
define input parameter par-is-all-pay     like ub.cash-pay.is-all-pay     no-undo .
define input parameter par-is-bar-read    like ub.cash-pay.is-bar-read    no-undo .
define input parameter par-is-card-swap   like ub.cash-pay.is-card-swap   no-undo .
define input parameter par-is-goods-pay   like ub.cash-pay.is-goods-pay   no-undo .
define input parameter par-is-service-pay like ub.cash-pay.is-service-pay no-undo .
define input parameter par-is-kbo         like ub.cash-pay.is-kbo no-undo .
define input parameter par-is-lnr         like ub.cash-pay.is-lnr no-undo .
define input parameter par-can-mix        like ub.cash-pay.can-mix no-undo .
define input parameter par-has-return     like ub.cash-pay.has-return no-undo .
define input parameter par-has-overpay    like ub.cash-pay.has-overpay no-undo .
define input parameter par-rule-file-name like ub.cash-pay.rule-file-name no-undo .
define input parameter par-slip-file-name like ub.cash-pay.slip-file-name no-undo .
define input parameter par-register       like ub.cash-pay.register no-undo .


define variable vss-revision    as character no-undo init "$Revision: b9071463af06, 3465, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:34 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashpay1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashpay1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в типе кассовых платежей".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE is-wth as logical no-undo .
DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
define variable v-mess as character no-undo .
define variable glog as logical no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_db for ub.db.
define buffer buf_chk-pay for ub.chk-pay.

do
on error undo, return error return-value
:
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
  if NOT (par-mode = {&add-def} OR par-mode = {&update}) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
    return error '':U.
  end.

  if par-mode = {&add-def} AND
    can-find(FIRST ub.cash-pay where
                  ub.cash-pay.cdpay-code = parcdpay-code AND
                  ub.cash-pay.curr-code = parcurr-code
                  ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parcdpay-code " parcdpay-code
    "и/или parcurr-code " parcurr-code
    "Уже есть тип кассового платежа:"  skip
    "Код платежа" parcdpay-code SKIP
    "Код валюты" parcurr-code
    view-as alert-box ERROR.
    return error '':U.
  end.
  
  run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
  if v-value = "no"  then do: 
  { gbl/getcntxt.i get }
  if v-cntxt-db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Запрещено создание и редактирование типа кассового платежа в УБД "
    view-as alert-box ERROR.
    return error '':U.
  end.
  end.
  run trg/cashpay2.p (
                   input p-silent
                  ,INPUT parcdpay-code
                  ,INPUT parobj-name
                  ,INPUT parcurr-code
                  ,INPUT parpay-code
                  ,INPUT parwth-code
                  ,INPUT parpay-limit
                  ,INPUT parpay-card-view
                  ) no-error.
  if error-status:error then do:
    return error return-value.
  end.

  if paris-cash then do:
    if par-is-credit-card
    or par-is-debet-card
    or par-atr128
    or (parpay-card-view <> "":U and p-silent)
    or par-is-card-swap
    or par-atr32
    or par-atr16
    or par-atr4 then do:
      v-mess = substitute("Платеж со свойством <Наличные> не может одновременно иметь свойства КРЕДИТНАЯ КАРТА, ДЕБЕТОВАЯ КАРТА,&1" +
                          "НЕОБХОДИМА ON-LINE АВТОРИЗАЦИЯ, ОБЯЗАТЕЛЕН ВВОД PIN-КОДА, <ПРОКАТЫВАТЬ КАРТУ>, ИСПОЛЬЗОВАТЬ СКАНЕР БАР-КОДОВ,&1"  +
                          "ПРЕФИКСЫ ПЛАТЕЖНЫХ КАРТ ДЛЯ ПРОСМОТРА, ПЛАТЕЖ ПО СМАРТ-КАРТЕ"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-cash':U).

    end.
  end.
  if paris-cash then do:
    if parpay-card-view <> "":U
    and not p-silent
    then do:
      message
      "Вы уверены, что платеж со свойством <Наличные> имеет" skip
      "ПРЕФИКСЫ ПЛАТЕЖНЫХ КАРТ ДЛЯ ПРОСМОТРА?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then return error "is-cash:U".
    end.
  end.
  if parcdpay-code = 1 then do:
    if paris-cash = no then do:
      v-mess = "Тип кассового платежа с кодом 1 ДОЛЖЕН  иметь свойство НАЛИЧНЫЕ".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-cash':U).
    end.
    if par-has-overpay = 1 then  do:
      v-mess = "Тип кассового платежа с кодом 1 НЕ ДОЛЖЕН  иметь свойство Разрешена переплата".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'has-overpay':U).
    end.
    if par-atr1 = no then do:
      v-mess = "Тип кассового платежа с кодом 1 ДОЛЖЕН  иметь свойство Разрешается сдача на платеж".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'atr1':U).
    end.
    if par-has-return = 0 then do:
      v-mess = "Тип кассового платежа с кодом 1 ДОЛЖЕН  иметь свойство Разрешен Возврат".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'has-return':U).
    end.
    if par-can-mix = 0 then do:
      v-mess = "Тип кассового платежа с кодом 1 ДОЛЖЕН  иметь свойство Разрешена смешанная оплата".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'can-mix':U).
    end.
  end.
  if par-is-credit = yes then do:
    if paris-cash
    or par-is-credit-card
    or par-is-advance
    then do:
      v-mess = "Платеж <В кредит> не может одновременно иметь свойства НАЛИЧНЫЕ, КРЕДИТНАЯ КАРТА, УЧЕТ АВАНСА".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-credit':U).
    end.
  end.

  if par-is-advance = yes then do:
    if paris-cash
    or par-is-credit-card
    or par-is-debet-card
    or par-is-credit
    then do:
      v-mess = "Платеж <Учет аванса> не может одновременно иметь свойства НАЛИЧНЫЕ, КРЕДИТНАЯ КАРТА, ДЕБЕТОВАЯ КАРТА, ПЛАТЕЖ В КРЕДИТ".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-advance':U).
    end.
  end.
  if par-is-kbo > 0 then do:
    if parcurr-code <> 0 then do:
       v-mess = substitute("Атрибут КБО можно задать только для типа кассового платежа с нац. валютой").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-kbo':U).
    end.
    if paris-cash = yes then do:
      v-mess = substitute("Нельзя задать атрибут КБО для типа кассового платежа, имеющего свойство НАЛИЧНЫЕ").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-kbo':U).
    end.
    if par-atr16 = yes then do:
      v-mess =  substitute("Нельзя задать атрибут КБО для типа кассового платежа, имеющего свойство НЕОБХОДИМА ОНЛАЙН АВТОРИЗАЦИЯ").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'is-kbo':U).
    end.
  end.
  if par-mode = {&add-def} then do:
    create buf_cash-pay.
    assign par-rid = recid(buf_cash-pay).
  end.
  else do:
    FIND FIRST buf_cash-pay EXCLUSIVE-LOCK WHERE
              recid(buf_cash-pay) = par-rid NO-WAIT No-ERROR.
    if locked buf_cash-pay then do:
      v-mess = "Запись типа кассового платежа занята".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if not avail buf_cash-pay then do:
      v-mess =  "Не найдена запись типа кассового платежа".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_cash-pay.cdpay-code <> parcdpay-code OR
    buf_cash-pay.curr-code <> parcurr-code then do:
      find first buf_db No-LOCK where buf_db.db-num > 0 No-ERROR.
      if not avail buf_db then do:
        FIND FIRST buf_chk-pay No-LOCK WHERE
                  buf_chk-pay.pay-code = parcdpay-code  AND
                  buf_chk-pay.curr-code = parcurr-code No-ERROR.
      end.
      if available buf_db or available buf_chk-pay then
      v-mess = substitute("&1 &2 &3 Для уже имеющейся записи нельзя изменить&4" +
                          "код типа платежа и код валюты&4" +
                          "в системе с УБД и/или если имеются чеки с таким типом кассового платежа"
                        , vss-workfile
                        ,vss-revision
                        ,vss-description
                        , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.

  assign
  buf_cash-pay.cdpay-code =  parcdpay-code
  buf_cash-pay.obj-name = parobj-name
  buf_cash-pay.curr-code = parcurr-code
  buf_cash-pay.pay-code = parpay-code
  buf_cash-pay.wth-code =  parwth-code
  buf_cash-pay.pay-limit = parpay-limit
  buf_cash-pay.is-cash = paris-cash
  buf_cash-pay.atr1 = par-atr1
  buf_cash-pay.atr2 =  par-atr2
  buf_cash-pay.atr4 =  par-atr4
  buf_cash-pay.atr8 =  par-atr8
  buf_cash-pay.atr16 = par-atr16
  buf_cash-pay.atr32 = par-atr32
  buf_cash-pay.atr64 = par-atr64
  buf_cash-pay.atr128 = par-atr128
  buf_cash-pay.pay-card-view = parpay-card-view
  buf_cash-pay.is-advance     = par-is-advance
  buf_cash-pay.is-credit      = par-is-credit
  buf_cash-pay.is-credit-card = par-is-credit-card
  buf_cash-pay.is-debet-card = par-is-debet-card
  buf_cash-pay.is-all-pay     =  par-is-all-pay
  buf_cash-pay.is-bar-read    =  par-is-bar-read
  buf_cash-pay.is-card-swap   =  par-is-card-swap
  buf_cash-pay.is-goods-pay   =  par-is-goods-pay
  buf_cash-pay.is-service-pay =  par-is-service-pay
  buf_cash-pay.is-kbo         =  par-is-kbo
  buf_cash-pay.is-lnr         =  par-is-lnr
  buf_cash-pay.can-mix        =  par-can-mix
  buf_cash-pay.has-return     =  par-has-return
  buf_cash-pay.has-overpay    =  par-has-overpay
  buf_cash-pay.rule-file-name =  par-rule-file-name
  buf_cash-pay.slip-file-name =  par-slip-file-name
  buf_cash-pay.status_        = (if par-mode = {&add-def} then  {&current-status} else buf_cash-pay.status_)
  buf_cash-pay.register       = par-register
  .
  release buf_cash-pay no-error.
  if error-status:error then do:
    v-mess = substitute("&1 &2 &3&4" +
                        "Ошибка при сохранении записи типа кассового платежа&4" +
                        "код платежа &5 код валюты &6&4&7&4&8"
                         ,vss-workfile
                         ,vss-revision
                         ,vss-description
                         ,{&new-line}
                         ,parcdpay-code
                         ,parcurr-code
                         , error-status:get-message(1)
                         , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  return '':U.
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then 
      do:
        assign
          p-mess = substitute("Тип касс.платежа с кодом &1 и кодом валюты &2&3&4"
                         , parcdpay-code
                         , parcurr-code
                         , {&new-line}
                         , p-mess)
          .
      end.

    when no then 
      do:
        if g#esys then 
        do:
        assign
          p-mess = substitute("Тип касс.платежа с кодом &1 и кодом валюты &2&3&4"
                         , parcdpay-code
                         , parcurr-code
                         , {&new-line}
                         , p-mess)
          .
          return error.
        end.
        else 
        do:

          message
            p-mess
            view-as alert-box error .
        end.
      end.
  end.
END PROCEDURE.