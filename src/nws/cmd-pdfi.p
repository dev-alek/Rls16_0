block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-pdfi.p $
$Archive: nws/cmd-pdfi.p $

Обработка команды по закрытой шапке ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 05/28/07
Author: Svetlana Chernova
Creation date: 05/28/07

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-par1 as integer   no-undo .
define input  parameter p-par2 as integer   no-undo .
define input  parameter p-par3 as integer   no-undo .
define input  parameter p-par4 as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-pdfi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-pdfi.p $":U .
define variable vss-description as character no-undo init "Обработка команды по закрытой шапке ДНЦ".
{ cmp/vssrevis.i "substitute('&1|&2|':u,p-counter,p-type)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .

define temp-table buf_temp-PDF no-undo like ub.price-doc-forming.
/* on WRITE of ub.price-doc-forming override do: end. */


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
      when {&table_price-doc-forming}
      then do:
        create buf_temp-PDF .
        run nws-impl in p-imp-handle
          ( input {&table_price-doc-forming}
           ,input (buffer buf_temp-PDF:handle)
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
  define buffer buf_price-doc-forming for ub.price-doc-forming  .
   for each buf_temp-PDF where
            buf_temp-PDF.pdf-id     = p-par1 AND
            buf_temp-PDF.pdf-db     = p-par2 AND
            buf_temp-PDF.plt-id     = p-par3 AND
            buf_temp-PDF.plt-db-num = p-par4
            :
       find first buf_price-doc-forming exclusive-lock
              where
              buf_price-doc-forming.pdf-id     = p-par1 AND
              buf_price-doc-forming.pdf-db     = p-par2 AND
              buf_price-doc-forming.plt-id     = p-par3 AND
              buf_price-doc-forming.plt-db-num = p-par4
              no-error .
                if  not available buf_price-doc-forming then do:
                    /* нет и не надо */
                    return  .
                end.
                case p-type :
                  when "status" then do:
                      assign
                        buf_price-doc-forming.stts = buf_temp-PDF.stts
                      .
                  end .
                  otherwise do:
                    message "Неизвестный тип команды" p-type .
                  end.
                end case.
    end.
   end.
end.