block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отправка в новости шапки schet-fact-doc при изменении в статусе FACT

Автор: Чернова Светлана Александровна
Дата создания: 05/28/07
Author: Svetlana Chernova
Creation date: 05/28/07

*/
define input  parameter p-doc-code  as character no-undo .
define input  parameter p-db-num  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отправка в новости шапки schet-fact-doc при изменении в статусе FACT".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable p-db-list as character no-undo .     /* куда отсылать */
define variable i-db-num as integer   no-undo .
define variable v-rec-ord as integer no-undo .
i-db-num = integer (p-db-num ).
define buffer buf_schet-fact-doc for ub.schet-fact-doc  .

find first buf_schet-fact-doc  no-lock where
           buf_schet-fact-doc.doc-code = p-doc-code and
           buf_schet-fact-doc.db-num   = i-db-num  .

p-db-list = p-db-num .


define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code        as integer   no-undo .

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
  v-command =  substitute("&2&1&3&1&4"
              , {&delim-cmd}
              , {&cmd-s-f-doc-fact}
              , p-doc-code
              , p-db-num
              ).
  run begin-create-command in v-cmd-proc-handle
    (input  v-command
    ,input  p-db-list
    ,output v-cmd-code
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", {&cmd-s-f-doc-fact} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  for each buf_schet-fact-doc exclusive-lock where
           buf_schet-fact-doc.doc-code  = p-doc-code and
           buf_schet-fact-doc.db-num    = i-db-num
  on error undo, return error return-value
  :
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code                          /* p-command-code */
      ,input {&table_schet-fact-doc}             /* p-dump-name    */
      ,input '+update':U
      ,input (buffer buf_schet-fact-doc :handle) /* p-tbl-handle   */
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", {&table_schet-fact-doc}, v-cmd-code ) skip
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