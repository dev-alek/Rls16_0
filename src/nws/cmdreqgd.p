block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmdreqgd.p $
$Archive: nws/cmdreqgd.p $

Запросить информацию обо всех товарах по указанному объекту

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdreqgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdreqgd.p $":U .
define variable vss-description as character no-undo init "Запросить информацию обо всех товарах по указанному объекту".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-obj-type,p-obj-code)" }
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

  if p-obj-type = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение типа объекта" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-obj-code = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение кода объекта" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'check-exist':u"
    v-object-exist
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке существования объекта" skip
      "Не найден объект" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/objdbnum.i
    p-obj-type
    p-obj-code
    v-db-num
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении номер базы данных" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-db-num = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Нельзя запросить информацию у объекта, принадлежащего ГБД"
      "Объект" p-obj-type p-obj-code skip
      "База данных" v-db-num skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/curdbnum.i
    v-cur-db-num
  }
  if v-cur-db-num <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Запрос на отправку информации о товарах из УБД может быть сформирован только в ГБД" skip
      "Объект" p-obj-type p-obj-code skip
      "База данных" v-db-num skip
      "Текущая база данных" v-cur-db-num skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

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

  run begin-create-command in v-cmd-proc-handle
    (input  {&cmd-request-goods} + {&delim-cmd} + string(p-obj-type) + {&delim-cmd} + string(p-obj-code) /* p-command-name */
    ,input "":U                                                                                          /* p-db-list      */
    ,output v-cmd-code1                                                                                  /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды test (1)!" ) skip
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

  define variable v-today         as date      no-undo .
  define variable v-time          as integer   no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-log-message   as character no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  assign
    v-log-file-name = 'cmdcmpgd.log':u
    v-log-message   = substitute("__ &1 &2 объект &3 &4 отправлен_запрос_на_передачу_остатков_из_УБД"
                                ,string(v-today,'99/99/9999':u)
                                ,string(v-time,'HH:MM:SS':U)
                                ,p-obj-type
                                ,p-obj-code
                                )
                    + {&new-line}
  .
  { gbl/file-wr.i
    v-log-file-name
    v-log-message
  }

end.