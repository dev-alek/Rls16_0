block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkprdoc.p $
$Archive: utl/chkprdoc.p $

Программа проверки документов переоценки

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/13/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: chkprdoc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/chkprdoc.p $":U .
define variable vss-description as character no-undo initial "Программа проверки документов переоценки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-today                    as date      no-undo .
define variable v-time                     as integer   no-undo .
define variable v-total-err-obj            as integer   no-undo .
define variable v-total-ind                as integer   no-undo .
define variable v-grand-total-err          as integer   no-undo .
define variable v-last-obj-type            as character no-undo .
define variable v-last-obj-code            as integer   no-undo .
define variable v-last-err-date            as date      no-undo .
define variable v-err-file-name            as character no-undo .
define variable v-log-file-name            as character no-undo .

define stream sout .

define variable v-object  as character no-undo .

define frame a
  v-object        format "x(40)"       label "Объект" skip
  v-total-ind     format ">>>,>>>,>>9" label "Проверено объектов" skip
  v-total-err-obj format ">>>,>>>,>>9" label "Объектов с ошибками" skip
  with view-as dialog-box side-labels three-d
  title "Проверка документов переоценки"
  .

do
on error undo, return error return-value
:
  assign
    v-log-file-name            = 'chkprdoc.txt':U
    v-err-file-name            = 'chkprdoc.err':U
  .

  { gbl/getcntxt.i get }

  define variable v-num                     as integer   no-undo .
  define variable v-ok                      as logical   no-undo .
  define variable v-check-start-date-string as character no-undo .
  define variable v-check-start-date        as date      no-undo .

  assign
    v-ok = false
  .

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Проверка документов переоценки" + {&new-line}
           + "Все переоценки или с определенной даты"
    ,input "|^"
    ,input "Все переоценки^confirm|С определенной даты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num
  :
    when 1
    then do:
      assign
        v-check-start-date = ?
      .
    end.
    when 2
    then do:
      run gbl/d-prompt.w
        ( 'title=':u + "Введите дату" + '\':u
        + 'text1=':u + "Введите дату, начиная с которой надо проверить переоценки" + '\':u
        + 'type=date\':u
        ,input-output v-check-start-date-string
        ).
      if return-value = 'false':u
      then do:
        /* отказ от расчета складского архива по товарам */
        undo, return error . /* --->>>--- */
      end.
      assign
        v-check-start-date = date(v-check-start-date-string)
      .
      if v-check-start-date = ?
      then do:
        message
          "Не выбрана дата" v-check-start-date-string skip
          view-as alert-box error .
        undo, return error . /* --->>>--- */
      end.
    end.
    when 3
    then do:
      undo, return error . /* --->>>--- */
    end.
  end.

  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Проверка документов переоценки" + {&new-line}
           + (if v-check-start-date <> ?
              then substitute("Проверка документов переоценки с даты &1 включительно"
                             ,string(v-check-start-date, '99/99/9999':U)
                             )
              else "Проверка документов переоценки за все даты"
             )
    ,input "|^"
    ,input "Все объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num
  :
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
          run check-price-doc in this-procedure
            (input buf_clients.obj-type
            ,input buf_clients.obj-code
            ,input v-check-start-date
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
        run check-price-doc in this-procedure
          (input buf_userobjs_temp-user-obj.obj-type
          ,input buf_userobjs_temp-user-obj.obj-code
          ,input v-check-start-date
          ).
      end.
    end.
    otherwise do:
      return . /* --->>>--- */
    end.
  end.

  hide frame a .

  if v-total-err-obj <> 0
  then do:
    message
      "Проверка складского архива по поставщикам" skip
      "" skip
      "Обнаружены ошибки в складском архиве по поставщикам" skip
      "Проверено объектов" v-total-ind skip
      "Всего объектов с ошибками" v-total-err-obj skip
      "Всего элементарных ошибок" v-grand-total-err skip
      "Список проверенных объектов выведен в файл" v-log-file-name skip
      "Список объектов с ошибками выведен в файл"  v-err-file-name skip
      view-as alert-box error .
  end.
  else do:
    message
      "Проверка складского архива по поставщикам закончена" skip
      "Проверено объектов" v-total-ind skip
      "Список проверенных объектов выведен в файл" v-log-file-name skip
      "Ошибок не обнаружено" skip
      view-as alert-box information .
  end.
end.


procedure check-price-doc :

  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-check-start-date as date      no-undo .

  define variable v-err-count         as integer   no-undo .
  define variable v-state-description as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-total-ind     = v-total-ind + 1
      v-last-obj-type = p-obj-type
      v-last-obj-code = p-obj-code
    .

    view frame a .

    display
      substitute('&1 &2', p-obj-type, p-obj-code) @ v-object
      v-total-err-obj       @ v-total-err-obj
      with frame a .

    output stream sout to value(v-log-file-name) append .
    export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
    export stream sout "Объект" p-obj-type p-obj-code .
    export stream sout "Начало проверки объекта".
    output stream sout close .

    run utl/chkobprd.p
      (input  p-obj-type          /* p-obj-type          */
      ,input  p-obj-code          /* p-obj-code          */
      ,input  p-check-start-date  /* p-start-date        */
      ,output v-err-count         /* p-err-num           */
      ,output v-state-description /* p-state-description */
      ) no-error .
    if error-status :error
    then do:
      output stream sout to value(v-log-file-name) append .
      export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
      export stream sout "Объект" p-obj-type p-obj-code .
      export stream sout "Аварийное завершение проверки объекта".
      export stream sout "Сообщение об ошибке" error-status :get-message(1) .
      export stream sout "Результат" return-value .
      output stream sout close .
    end.

    output stream sout to value(v-log-file-name) append .
    export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
    export stream sout "Объект" p-obj-type p-obj-code .
    export stream sout "Завершена проверка объекта".
    export stream sout "Ошибок" v-err-count .
    export stream sout v-state-description .
    output stream sout close .

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

      output stream sout to value(v-err-file-name) append .
      export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
      export stream sout "Объект" p-obj-type p-obj-code .
      export stream sout "Ошибок" v-err-count .
      export stream sout v-state-description .
      output stream sout close .
    end.
  end.

end procedure. /* check-price-doc */