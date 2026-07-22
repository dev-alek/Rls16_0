block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: blbr-upd.p $
$Archive: utl/blbr-upd.p $

Утилита корректирующая раскурутку БД для Блекбери

Автор: Белоусов Илья Александрович
Дата создания: 03/11/09
Author: Ilia Belousov
Creation date: 03/11/09

*/

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: blbr-upd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/blbr-upd.p $":U .
define variable vss-description as character no-undo init "Утилита корректирующая раскурутку БД для Блекбери".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

{ gbl/waitfram.i }
{ ref/cgrplbfn.i }

define buffer buf_cli-grp           for ub.cli-grp .
define buffer buf_clients           for ub.clients .
define buffer buf_wealth            for ub.wealth .
define buffer buf_cash-pay          for ub.cash-pay .

disable triggers for load of ub.cli-grp .
disable triggers for load of ub.clients .
disable triggers for load of ub.cash-pay .
disable triggers for load of ub.wealth .

do
on error undo, return error
:
  run waitfram-show in this-procedure ("Инициализация групп клиентов" ) .
  run upd-cli-grp in this-procedure ( "Свои объекты, фирмы" ) .
  run upd-cli-grp in this-procedure ( "Производители и поставщики" ) .
  run upd-cli-grp in this-procedure ( "Покупатели" ) .
  run upd-cli-grp in this-procedure ( "Персонал" ) .

  run waitfram-show in this-procedure ("Инициализация клиентов").
  run upd-cli in this-procedure ( "Реализация в магазине", "Покупатели" ) .

  run waitfram-show in this-procedure ("Инициализация МЦ").
  run upd-wth in this-procedure ( 1, 0, YES, "Наличные", {&wth-qnty-sum} ) .

  run waitfram-show in this-procedure ("Инициализация типов кассовых платежей").
  run upd-cash-pay in this-procedure (  1, 0, 1, 1, "Наличные",          TRUE, FALSE ) .
  run upd-cash-pay in this-procedure ( 20, 0, 1, 0, "Оплата по кредиту", FALSE, TRUE ) .

  /*
  run upd-cli-0 in this-procedure .
  */
end.


procedure upd-cli-grp :
define input parameter p-grp-name as character        no-undo.

do
on error undo, return error
:

  define buffer buf_cli-grp for ub.cli-grp .

  for each buf_cli-grp
     WHERE buf_cli-grp.node-name = p-grp-name
       AND buf_cli-grp.upper-code = 0
       EXCLUSIVE-LOCK
       :
        DELETE buf_cli-grp .
  end.

end. /* do on error */
end procedure. /* upd-cli-grp */




/*==========================================================================*/
procedure upd-cli :
define input parameter p-obj-name as character        no-undo.
define input parameter p-grp-name as character        no-undo.

define variable v-name    as character    no-undo.
define variable v-obj-code    as integer      no-undo.

do
on error undo, return error
:

   find first buf_clients
        WHERE buf_clients.obj-name = p-obj-name
       EXCLUSIVE-LOCK
        NO-ERROR
        .

   run cli-grplib-get-full-name in this-procedure
      ( input  buf_clients.grp-code
      , output v-name
      ).

   IF AVAILABLE buf_clients
   then do:
      ASSIGN
         buf_clients.grp-name = v-name
         buf_clients.is-prod  = FALSE
         buf_clients.sup-gds  = FALSE
         buf_clients.buy-gds  = FALSE
         buf_clients.buy-serv = FALSE
         buf_clients.buy-cons = FALSE
         buf_clients.sup-cons = FALSE
         buf_clients.sup-serv = FALSE
      .
  end.

end. /* do on error */
end procedure. /* upd-cli */




/*==========================================================================*/
procedure upd-wth :
define input parameter p-code as integer          no-undo.
define input parameter p-curr-code as integer          no-undo.
define input parameter p-is-money as logical          no-undo.
define input parameter p-name as character        no-undo.
define input parameter p-get-qnty-method as character        no-undo.

do
on error undo, return error
:

   find first buf_wealth
        WHERE buf_wealth.wth-code = p-code
       EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_wealth
   then do:
      ASSIGN
         buf_wealth.get-qnty-method = p-get-qnty-method
      .
   END.

end. /* do on error */
end procedure. /* upd-wth */




/*==========================================================================*/
procedure upd-cash-pay :
define input parameter p-code       as integer          no-undo.
define input parameter p-curr-code  as integer          no-undo.
define input parameter p-type       as integer          no-undo.
define input parameter p-wth        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-is-cash    as logical          no-undo.
define input parameter p-is-credit  as logical          no-undo.

do
on error undo, return error
:

   find first buf_cash-pay
                   WHERE buf_cash-pay.cdpay-code = p-code
                     AND buf_cash-pay.curr-code  = p-curr-code
       EXCLUSIVE-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_cash-pay
   then do:
      ASSIGN
         buf_cash-pay.atr1       = TRUE
         buf_cash-pay.atr2       = TRUE
         buf_cash-pay.is-cash    = p-is-cash
         buf_cash-pay.is-credit  = p-is-credit
         buf_cash-pay.status_    = {&current-status}
         buf_cash-pay.is-all-pay = p-is-cash
         buf_cash-pay.can-mix     = INTEGER(p-is-cash)
         buf_cash-pay.has-overpay = INTEGER(p-is-credit)
      .
   END.

end. /* do on error */
end procedure. /* upd-cash-pay */
