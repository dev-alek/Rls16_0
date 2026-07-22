block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-rcvi.p $
$Archive: nws/cmd-rcvi.p $

Обработка команды по шапке поставки в статусе ПОСТАВКА

Автор: Чернова Светлана Александровна
Дата создания: 08/15/07
Author: Svetlana Chernova
Creation date: 08/15/07

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-rcv-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-rcvi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-rcvi.p $":U .
define variable vss-description as character no-undo init "Обработка команды по шапке поставки в статусе ПОСТАВКА".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter,p-type,p-doc-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .

define temp-table buf_temp-ord-doc-rcv no-undo like ub.ord-doc-rcv.
on WRITE of ub.ord-doc-rcv override do: end.


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Получение изменений шапки поставки в статусе ПОСТАВКА Получено &1", counter)
        ) .
    end.

    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
    .

    CASE entry(1, v-rec-name, {&delim-par}) :
      when {&table_ord-doc-rcv}
      then do:
        create buf_temp-ord-doc-rcv .
        run nws-impl in p-imp-handle
          ( input {&table_ord-doc-rcv}
           ,input (buffer buf_temp-ord-doc-rcv:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          view-as alert-box error .
        return error .
      end.
    end case.
  end.

  run waitfram-hide .

  /* обработка команды */

  define variable v-ind as integer   no-undo .

  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
   for each buf_temp-ord-doc-rcv where buf_temp-ord-doc-rcv.doc-code = p-doc-code and buf_temp-ord-doc-rcv.rcv-code = p-rcv-code :
       find first buf_ord-doc-rcv exclusive-lock
              where buf_ord-doc-rcv.doc-code = p-doc-code and buf_ord-doc-rcv.rcv-code = p-rcv-code  no-error .
                if  not available buf_ord-doc-rcv then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        error-status :get-message(1)
                        "При поиске поставки №" p-rcv-code p-doc-code
                        view-as alert-box error .
                      return error .
                end.
        assign
          buf_ord-doc-rcv.ship-date      = buf_temp-ord-doc-rcv.ship-date
          buf_ord-doc-rcv.ship-time      = buf_temp-ord-doc-rcv.ship-time
          buf_ord-doc-rcv.fact-ship-time = buf_temp-ord-doc-rcv.fact-ship-time
        .
    end.
   end.
end.