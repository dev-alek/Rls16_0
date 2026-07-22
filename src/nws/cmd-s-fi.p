block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-s-fi.p $
$Archive: nws/cmd-s-fi.p $

Обработка команды по шапке счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 08/15/07
Author: Svetlana Chernova
Creation date: 08/15/07

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-type       as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-db-num     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-s-fi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-s-fi.p $":U .
define variable vss-description as character no-undo init "Обработка команды по шапке счета-фактуры".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter,p-type,p-doc-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .
define variable i-db-num   as integer   no-undo .

i-db-num = integer(p-db-num).

define temp-table buf_temp-schet-fact-doc no-undo like ub.schet-fact-doc.
on WRITE of ub.schet-fact-doc override do: end.


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
        (input substitute("Получение изменений шапки счета-фактуры в статусе ФАКТ Получено &1", counter)
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
      when {&table_schet-fact-doc}
      then do:
        create buf_temp-schet-fact-doc .
        run nws-impl in p-imp-handle
          ( input {&table_schet-fact-doc}
           ,input (buffer buf_temp-schet-fact-doc:handle)
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
  define buffer buf_schet-fact-doc for ub.schet-fact-doc  .

   for each buf_temp-schet-fact-doc where buf_temp-schet-fact-doc.doc-code = p-doc-code and buf_temp-schet-fact-doc.db-num = i-db-num :
       find first buf_schet-fact-doc exclusive-lock
              where buf_schet-fact-doc.doc-code = p-doc-code and buf_schet-fact-doc.db-num = i-db-num  no-error .
        if   available buf_schet-fact-doc then do:
                buffer-copy  buf_temp-schet-fact-doc EXCEPT db-num
                                                            doc-code
                                                            fact-order
                                                            fact-time
                                                            sys-date
                                                            sys-time
                to buf_schet-fact-doc .
       end.
    end.
   end.
end.