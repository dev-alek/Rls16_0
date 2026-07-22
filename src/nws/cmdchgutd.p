block-level on error undo, throw.
/*

$Revision: f63859adafce, 2420, rls $
$Author: ASMorozov $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: cmdchgutd.p $
$Archive: nws/cmdchgutd.p $

Комманда на изменения статуса UTD/УТД

Автор: Морозов Александр Сергеевич
Дата создания: 15/03/2020
Author: Alexandr Morozov
Creation date: 15/03/2020

*/

define parameter buffer buf_utd for ub.utd.

define variable vss-revision    as character no-undo init "$Revision: f63859adafce, 2420, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdchgutd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdchgutd.p $":U .
define variable vss-description as character no-undo init "Запросить информацию обо всех товарах по указанному объекту".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,buf_utd.db-num,buf_utd.doc-id,buf_utd.sts)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-db-num          as integer   no-undo .
define variable v-cur-db-num      as integer   no-undo .
define variable v-object-exist    as logical   no-undo .
define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code1       as integer   no-undo .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

define buffer buf_clients for ub.clients.


/*  { gbl/curdbnum.i                                                                             */
/*    v-cur-db-num                                                                               */
/*  }                                                                                            */
/*  if v-cur-db-num <> 0                                                                         */
/*  then do:                                                                                     */
/*    message                                                                                    */
/*      vss-workfile vss-revision vss-description skip                                           */
/*      "Ошибка задания входных параметров" skip                                                 */
/*      "Запрос на отправку информации о товарах из УБД может быть сформирован только в ГБД" skip*/
/*      "Объект" p-obj-type p-obj-code skip                                                      */
/*      "База данных" v-db-num skip                                                              */
/*      "Текущая база данных" v-cur-db-num skip                                                  */
/*      error-status :get-message(1) skip                                                        */
/*      return-value skip                                                                        */
/*      view-as alert-box error .                                                                */
/*    undo, return error return-value .                                                          */
/*  end.                                                                                         */

  run nws/cmd-bush.p persistent set v-cmd-proc-handle
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске библиотеки отправки команд cmd-bush.p") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  find first buf_clients no-lock where buf_clients.obj-type = buf_utd.obj-type and buf_clients.obj-code = buf_utd.obj-code no-error.
  
  if not available (buf_clients) or buf_clients.db-num = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды на изменения статуса УТД (1)! Не задан/неверный объект в документе УТД. &1 &2", buf_utd.db-num, buf_utd.doc-id ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.
  
  v-db-num = buf_clients.db-num.
  if v-db-num = g#db-num
    then return.

  run begin-create-command in v-cmd-proc-handle
    (input  {&cmd-chg-utd-sts} + {&delim-cmd} + string(buf_utd.db-num) + {&delim-cmd} + string(buf_utd.doc-id) + {&delim-cmd} + string(buf_utd.sts) + {&delim-cmd} + string(buf_utd.sts-edi) + {&delim-cmd} + string(buf_utd.doc-code) /* p-command-name */
    ,input "":U                                                                                          /* p-db-list      */
    ,output v-cmd-code1                                                                                  /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды на изменения статуса УТД (1)!" ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  run send-command in v-cmd-proc-handle
    (input v-cmd-code1      /* p-command-code */
    ,input string(v-db-num) /* p-db-list      */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отправке в новости команды с кодом &1", v-cmd-code1 ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo, return error return-value .
  end.

  delete procedure v-cmd-proc-handle .

/*  define variable v-today         as date      no-undo .*/
/*  define variable v-time          as integer   no-undo .*/
/*  define variable v-log-file-name as character no-undo .*/
/*  define variable v-log-message   as character no-undo .*/

/*  run cur-time in this-procedure*/
/*    (output v-today             */
/*    ,output v-time              */
/*    ) .                         */

/*  assign                                                                                             */
/*    v-log-file-name = 'cmdcmpgd.log':u                                                               */
/*    v-log-message   = substitute("__ &1 &2 объект &3 &4 отправлен_запрос_на_передачу_остатков_из_УБД"*/
/*                                ,string(v-today,'99/99/9999':u)                                      */
/*                                ,string(v-time,'HH:MM:SS':U)                                         */
/*                                ,p-obj-type                                                          */
/*                                ,p-obj-code                                                          */
/*                                )                                                                    */
/*                    + {&new-line}                                                                    */
/*  .                                                                                                  */
/*  { gbl/file-wr.i  */
/*    v-log-file-name*/
/*    v-log-message  */
/*  }                */

end.