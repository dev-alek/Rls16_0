block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отправка в новости temp-table like parts

Автор: Чернова Светлана Александровна
Дата создания: 05/28/07
Author: Svetlana Chernova
Creation date: 05/28/07

*/

DEFINE TEMP-TABLE x_parts LIKE ub.parts.

define input  parameter p-doc-code as character no-undo .
define input  parameter table for x_parts.
define input  parameter p-comand-type as character no-undo . /* cmd-parts-fact-corr - корректировка закрытых ПН */
define input  parameter p-db-list     as character no-undo . /* куда отсылать */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отправка в новости temp-table like parts".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code        as integer   no-undo .
define variable v-db-list as character no-undo .
define variable v-rec-ord as integer no-undo .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  /* инициализируем библиотеку формирования команды */
  run nws/cmd-bush.p persistent set v-cmd-proc-handle
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске процедуры cmd-bush.p") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  /* начало формирования команды */
  define variable v-command as character no-undo .
  v-command =  substitute("&2&1&3&1&4&1&5&1&6&1&7"
              , {&delim-cmd}
              , {&cmd-parts-fact-corr}
              , p-comand-type
              , p-doc-code
              ).
  v-db-list = p-db-list .
  run begin-create-command in v-cmd-proc-handle
    (input  v-command
    ,input  v-db-list
    ,output v-cmd-code
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", {&cmd-parts-fact-corr} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  for each x_parts exclusive-lock
  on error undo, return error return-value
  :
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code                   /* p-command-code */
      ,input {&table_parts}               /* p-dump-name    */
      ,input '+update':U
      ,input (buffer x_parts :handle)     /* p-tbl-handle   */
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_parts}, v-cmd-code ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.

  end.

  /* завершить формирование команды и отправить информацию по новостям */
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code  /* p-command-code */
     ,input p-db-list   /* p-db-list      */
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отправке в новости команды с кодом &1", v-cmd-code ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  delete procedure v-cmd-proc-handle .
end.