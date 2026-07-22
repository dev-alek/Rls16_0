block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-cori.p $
$Archive: nws/cmd-cori.p $

Обработка команды по временной таблице parts

Автор: Чернова Светлана Александровна
Дата создания: 05/28/07
Author: Svetlana Chernova
Creation date: 05/28/07

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-type       as character no-undo .
define input  parameter p-par1       as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-cori.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-cori.p $":U .
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

define temp-table x_parts no-undo like ub.parts.

/* on WRITE of ub.parts override do: end. */

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop",   vss-workfile )
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
        (input substitute("Получение новых партий &1", counter)
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
      when {&table_parts}
      then do:
        create  x_parts .
        run nws-impl in p-imp-handle
          ( input {&table_parts}
           ,input (buffer x_parts:handle)
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
  define variable p-doc-code as character no-undo .
      for each x_parts :
         /* message 'Посмотрим что пришло' skip x_parts.in-code  x_parts.artic  x_parts.obj-type x_parts.obj-code skip p-par1 view-as alert-box . */
         p-doc-code = x_parts.in-code .
      end.
      run utl/trnfactb.p
        ( input ? ,
          input p-doc-code ,
          input table x_parts ) no-error .
          if error-status :error then do:
              return error return-value .
          end.
   end.
end.