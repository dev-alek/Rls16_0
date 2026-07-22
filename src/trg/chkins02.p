block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности строки оплат чека

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


define input parameter pardoc-code like ub.chk-pay.doc-code no-undo .
/*товарный чек - 0 или чек МЦ  - 1*/
define input parameter pardoc-type as integer no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter parchk-date like ub.chk-doc.chk-date no-undo .
define input parameter parchk-time like ub.chk-doc.chk-time no-undo .
define input parameter parpay-code like ub.chk-pay.pay-code no-undo .
define input parameter parcurr-code like ub.chk-pay.curr-code no-undo .
define input parameter parbase-code like ub.sysconf.base-code no-undo .
define input parameter r-b as character no-undo .
define input parameter parcas-curs as logical no-undo .
/*кур валюты оплаты по отношению к базовой валюте кассы*/
define input-output parameter parcash-rate like ub.chk-pay.cash-rate no-undo .
/*курс ЦБ для валюты оплаты -0 по отношению к р_у_блю*/
define input-output parameter parbank-rate like ub.chk-pay.bank-rate no-undo .
define input-output parameter parbank-scale like ub.chk-pay.bank-scale no-undo .
define input parameter par-rid as recid no-undo .
/*курс базовой валюты фирмы по отношениею к р_у_блю*/
define output parameter parbase-curs as decimal no-undo .
/*курс валюты оплаты по отношению к р_у_блю*/
define output parameter paropl-curs as decimal no-undo .
define output parameter p-par-code as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности строки оплат чека".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
DEFINE VARIABLE v-base-curs as character no-undo .
DEFINE VARIABLE v-bank-curs as character no-undo .
DEFINE VARIABLE v-opl-curs as character no-undo .
DEFINE VARIABLE varcash-rate like ub.chk-pay.cash-rate no-undo .
DEFINE VARIABLE varbank-rate like ub.chk-pay.bank-rate no-undo .
DEFINE VARIABLE varbank-scale like ub.chk-pay.bank-scale no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_curr-bank for ub.curr-bank.
define buffer buf_wealth for ub.wealth.


assign
varbank-rate = parbank-rate
varbank-scale = parbank-scale
.

if parbase-code = 0 then
assign
parbase-curs = 1
.
if parcurr-code = 0 then
assign
paropl-curs = 1
.
if r-b = "rubl":U and parcurr-code = 0 then
varcash-rate = 1
.


FIND FIRST buf_cash-pay WHERE
           buf_cash-pay.cdpay-code = parpay-code AND
           buf_cash-pay.curr-code = parcurr-code NO-LOCK NO-ERROR.
IF not avail buf_cash-pay then do:
   message
   substitute("Нет типа кассового платежа с кодом &1 и кодом валюты &2",  parpay-code, parcurr-code)
   view-as alert-box ERROR .
   return error.
end.

/*курс валюты платежа на кассе равен = валюта платежа к р_у_блю / базовая на кассе к р_у_блю */
/* если r-b = rubl и base-code = 0 то не найдо искать курс базовой на кассе  он равен 1*/

if r-b = "base":U and
  parbase-code <> 0 then do:
    /*найдем курс баз вал*/
  FIND LAST buf_curr-shop NO-LOCK Where
            buf_curr-shop.obj-type = parobj-type AND
            buf_curr-shop.obj-code  = parobj-code AND
            buf_curr-shop.curr-code = parbase-code AND
            ( ( buf_curr-shop.exch-date = parchk-date AND
                buf_curr-shop.exch-time <= parchk-time ) OR
                buf_curr-shop.exch-date < parchk-date ) NO-ERROR .
        IF NOT AVAIL buf_curr-shop then do:
          if not parcas-curs or parcash-rate = 0 then do:
            message
            "Нет магазинного курса базовой валюты на дату и время чека!" skip
            "(чек " pardoc-code  " - дата " string(parchk-date, "99/99/9999")
            " время - " string(parchk-time, "hh:mm")
            view-as alert-box ERROR.
            return error.
          end.
        end.
        if avail buf_curr-shop then
        parbase-curs = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale.
  if parcurr-code = parbase-code then
  paropl-curs = parbase-curs.
end.
/*еще не знаем*/
if paropl-curs = 0 then do:
     /*найдем курс валюты оплаты*/
      FIND LAST buf_curr-shop NO-LOCK Where
                buf_curr-shop.obj-type = parobj-type AND
                buf_curr-shop.obj-code  = parobj-code AND
                buf_curr-shop.curr-code = buf_cash-pay.curr-code AND
                ( ( buf_curr-shop.exch-date = parchk-date AND
                    buf_curr-shop.exch-time <= parchk-time ) OR
                  buf_curr-shop.exch-date < parchk-date ) NO-ERROR .
      IF not avail buf_curr-shop then do:
        if not parcas-curs or parcash-rate = 0 then do:
          message
          substitute("Нет магазинного курса валюты с кодом &1 на дату и время чека!&2" +
                     "(чек &3  - дата &4 время - &5)"
                     , buf_cash-pay.curr-code
                     , {&new-line}
                     , pardoc-code
                     ,string(parchk-date, "99/99/9999")
                     ,string(parchk-time, "hh:mm")
                     )
          view-as alert-box ERROR.
          return error.
        end.
      end.
      if avail BUF_curr-shop then
      paropl-curs = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale.
end.
if r-b = "rubl":U then
varcash-rate = paropl-curs.
if varcash-rate = 0 then
assign
varcash-rate = paropl-curs / parbase-curs
.
if parcurr-code = 0 then do:
  assign
  varbank-rate = 1
  varbank-scale = 1
  .

end.
else do:
  FIND FIRST buf_curr-bank No-LOCK WHERE
              buf_curr-bank.curr-code = parcurr-code AND
              buf_curr-bank.exch-date <= parchk-date  NO-ERROR .
  if not avail buf_curr-bank then do:
    if not parcas-curs or varbank-rate = 0 then do:
      message
      substitute( "Нет курса ЦБ для валюты с кодом &1 на дату чека!&2" +
                 "(чек &3  - дата  &4)"
                 , buf_cash-pay.curr-code
                 , {&new-line}
                 , pardoc-code
                 , string(parchk-date, "99/99/9999")
                 )
      view-as alert-box ERROR.
      return error.
    end.
  end.
  if avail buf_curr-bank then
  assign
  varbank-rate = buf_curr-bank.exch-rate
  varbank-scale = buf_curr-bank.exch-scale
  .
end.

if not parcas-curs and
  NOT (parcash-rate = 0 AND
       parbank-rate = 0 AND
       parbank-scale = 0 ) and
  not (parcash-rate = varcash-rate AND
       parbank-rate = varbank-rate AND
       parbank-scale = varbank-scale) then do:
  message
  substitute("Неверный курс валюты оплаты в магазине и/или &1"  +
             "неверный курс валюты ЦБ РФ"
             , {&new-line})
  view-as alert-box error .
  return error.
end.
if parcas-curs then do:
  if  parcash-rate = 0 then
  parcash-rate = varcash-rate.
  if (parbank-rate = 0 AND
       parbank-scale = 0 ) then
  assign
  parbank-rate = varbank-rate
  parbank-scale = varbank-scale
  .
  return.
end.
assign
parcash-rate = varcash-rate
parbank-rate = varbank-rate
parbank-scale = varbank-scale
.