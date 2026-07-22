block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cas-arh.p $
$Archive: utl/cas-arh.p $

Программа проверки скдадского архива по товарам

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/24/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: cas-arh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/cas-arh.p $":U .
define variable vss-description as character no-undo initial "Программа проверки складского архива по товарам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-today           as date      no-undo .
define variable v-time            as integer   no-undo .
define variable v-total-err-obj   as integer   no-undo .
define variable v-total-ind       as integer   no-undo .
define variable v-grand-total-err as integer   no-undo .
define variable v-last-obj-type   as character no-undo .
define variable v-last-obj-code   as integer   no-undo .
define variable v-last-err-date   as date      no-undo .

define variable v-log-file-name   as character no-undo .
define variable v-error-file-name as character no-undo .

define stream sout .

define variable v-object  as character no-undo .

define frame a
  v-object        format "x(40)"       label "Объект" skip
  v-total-ind     format ">>>,>>>,>>9" label "Проверено объектов" skip
  v-total-err-obj format ">>>,>>>,>>9" label "Объектов с ошибками" skip
  with view-as dialog-box side-labels three-d
  title "Проверка складского архива по товарам"
  .

do
on error undo, return error return-value
:
  assign
    v-log-file-name   = 'cas-arh.log':U
    v-error-file-name = 'cas-arh.txt':U
  .

  define variable v-num as integer no-undo .

  { gbl/getcntxt.i get }

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Проверка целостности складского архива по товарам" + {&new-line}
    ,input "|^"
    ,input "Все объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num :
    when 1
    then do:
      define buffer buf_db for ub.db .
      define buffer buf_clients for ub.clients .
      for each buf_db no-lock
      ,each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      on error undo, return error return-value
      :
        if buf_clients.stts = 0
        then do:
          run check-archive-arh in this-procedure
            (input buf_clients.obj-type
            ,input buf_clients.obj-code
            ).
        end.
      end.
    end.
    when 2
    then do:

      define variable v-user-select as logical   no-undo .
      { gbl/uobjsman.i
        parparentproc
        v-cntxt-db-num
        v-cntxt-userid
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-user-select
      }
      if v-user-select <> true
      then do:
        message
          "Объект не выбран"
          view-as alert-box information .
        return .
      end.

      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        run check-archive-arh in this-procedure
          (input buf_userobjs_temp-user-obj.obj-type
          ,input buf_userobjs_temp-user-obj.obj-code
          ).
      end.
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end.

  if v-total-err-obj <> 0
  then do:
    message
      "Проверка складского архива по товарам" skip
      "" skip
      "Обнаружены ошибки в складском архиве по товарам" skip
      "Проверено объектов" v-total-ind skip
      "Всего объектов с ошибками" v-total-err-obj skip
      "Всего элементарных ошибок" v-grand-total-err skip
      "Список проверенных объектов выведен в файл" v-log-file-name skip
      "Список объектов с ошибками выведен в файл" v-error-file-name skip
      view-as alert-box error .
  end.
  else do:
    message
      "Проверка складского архива по товарам закончена" skip
      "" skip
      "Ошибок не обнаружено" skip
      "Проверено объектов" v-total-ind skip
      "Список проверенных объектов выведен в файл" v-log-file-name skip
      view-as alert-box information .
  end.
end.


procedure check-archive-arh :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define variable v-create-chip-num        as integer   no-undo .
  define variable v-err-count              as integer   no-undo .
  define variable v-last-date              as date      no-undo .
  define variable v-error-description      as character no-undo .
  define variable v-detail-error-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-total-ind     = v-total-ind + 1
      v-last-obj-type = p-obj-type
      v-last-obj-code = p-obj-code
    .

    run utl/arhichk.p
      (input  p-obj-type                     /* p-obj-type         */
      ,input  p-obj-code                     /* p-obj-code         */
      ,input  {&btpr-type-arh}               /* p-archive-type     */
      ,input  {&archive-history-check-start} /* p-action-type      */
      ,input  ?                              /* p-start-check-date */
      ,input  0                              /* p-error-number     */
      ,input  ''                             /* p-status-message   */
      ,output v-create-chip-num              /* p-create-chip-num  */
      ) .

    output stream sout to value(v-log-file-name) append .
    export stream sout '###':U string(v-today, '99/99/9999':U) string(v-time, 'HH:MM:SS':U) .
    export stream sout "Начало проверки целостности складского архива по товарам" .
    export stream sout "Объект" p-obj-type p-obj-code .
    output stream sout close .

    view frame a .

    display
      substitute('&1 &2', p-obj-type, p-obj-code) @ v-object
      v-total-err-obj       @ v-total-err-obj
      with frame a .

    run utl/car-arh.p
      (input  p-obj-type               /* p-obj-type               */
      ,input  p-obj-code               /* p-obj-code               */
      ,output v-err-count              /* p-err-num                */
      ,output v-last-date              /* p-last-date              */
      ,output v-error-description      /* p-error-description      */
      ,output v-detail-error-file-name /* p-detail-error-file-name */
      ) .
    if v-err-count <> 0
    then do:
      assign
        v-total-err-obj = v-total-err-obj + 1
      .

      assign
        v-grand-total-err = v-grand-total-err + v-err-count
      .

      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ) .

      output stream sout to value(v-error-file-name) append .
      export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
      export stream sout "Завершена проверка складского архива по товарам" .
      export stream sout "Объект" p-obj-type p-obj-code .
      export stream sout "Ошибок" v-err-count .
      export stream sout "Последняя ошибочная дата" string(v-last-date, '99/99/9999':u) .
      export stream sout "Подробная информация об ошибках выведена в файл" v-detail-error-file-name .
      export stream sout v-error-description .
      output stream sout close .

      assign
        v-last-err-date = v-last-date
      .
    end.
    else do:
      assign
        v-last-err-date = ?
      .
    end.

    output stream sout to value(v-log-file-name) append .
    export stream sout '###':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
    export stream sout "Завершена проверка складского архива по товарам" .
    export stream sout "Объект" p-obj-type p-obj-code .
    export stream sout "Ошибок" v-err-count .
    export stream sout "Последняя ошибочная дата" string(v-last-date, '99/99/9999':u) .
    export stream sout "Подробная информация об ошибках выведена в файл" v-detail-error-file-name .
    export stream sout v-error-description .
    output stream sout close .

    run utl/arhichk.p
      (input  p-obj-type                    /* p-obj-type         */
      ,input  p-obj-code                    /* p-obj-code         */
      ,input  {&btpr-type-arh}              /* p-archive-type     */
      ,input  {&archive-history-check-stop} /* p-action-type      */
      ,input  ?                             /* p-start-check-date */
      ,input  v-err-count                   /* p-error-number     */
      ,input  v-error-description           /* p-status-message   */
      ,output v-create-chip-num             /* p-create-chip-num  */
      ) .

    hide frame a .
  end.

end procedure. /* check-archive-arh */