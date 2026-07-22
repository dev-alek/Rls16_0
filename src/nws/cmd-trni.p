block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-trni.p $
$Archive: nws/cmd-trni.p $

Обработка команды по закрытой шапки накладной

Автор: Чернова Светлана Александровна
Дата создания: 05/28/07
Author: Svetlana Chernova
Creation date: 05/28/07

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-trni.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-trni.p $":U .
define variable vss-description as character no-undo init "Обработка команды по закрытой шапки накладной".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter,p-type,p-doc-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .

define temp-table buf_temp-trn-doc no-undo like ub.trn-doc.
on WRITE of ub.trn-doc override do: end.


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
        (input substitute("Получение изменений шапки накладной Получено &1", counter)
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
      when {&table_trn-doc}
      then do:
        create buf_temp-trn-doc .
        run nws-impl in p-imp-handle
          ( input {&table_trn-doc}
           ,input (buffer buf_temp-trn-doc:handle)
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
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  define buffer buf_trn-doc for ub.trn-doc  .
   for each buf_temp-trn-doc where buf_temp-trn-doc.doc-code = p-doc-code :
       find first buf_trn-doc exclusive-lock
              where buf_trn-doc.doc-code = p-doc-code no-error .
                if  not available buf_trn-doc then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        error-status :get-message(1)
                        "При поиске накладной №" p-doc-code
                        view-as alert-box error .
                      return error .
                end.
                case p-type :
                  when "fo" then do:
                      assign
                        buf_trn-doc.buyer-fo-date = buf_temp-trn-doc.buyer-fo-date
                        buf_trn-doc.cr-fo-buyer   = buf_temp-trn-doc.cr-fo-buyer
                        buf_trn-doc.need-buyer    = buf_temp-trn-doc.need-buyer
                      .
                  end .
                  when "factur" then do:
                      assign
                        buf_trn-doc.factur-date = buf_temp-trn-doc.factur-date
                        buf_trn-doc.cr-factur   = buf_temp-trn-doc.cr-factur
                        buf_trn-doc.need-factur = buf_temp-trn-doc.need-factur
                      .
                  end .
                  otherwise do:
                    message "Неизвестный тип команды" p-type .
                  end.
                end case.
    end.
   end.
end.