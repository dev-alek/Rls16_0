block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: sibinek-soft $
$Date: 12/09/2025 $
$Workfile: cutldubd.p $
$Archive: utl/cutldubd.p $

Чистка БД

Автор: Ростовцев Александр
Дата создания: 12.09.2025
Author: Aleksandr Rostovtsev
Creation date: 12/09/2025

*/

/* Parameters Definitions ---                                           */

define input parameter p-date-actual-docs    as date      no-undo .
define input parameter p-handle-callback     as handle    no-undo . /* вопросительный знак или указатель на вызываемую процедуру */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 10/07/2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clean_db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/clean_db.p $":U .
define variable vss-description as character no-undo init "Чистка базы данных до даты".
{ cmp/str-glbl.i }
{ utl/cut-load.i &filename="clean_db.log"}

/* Local Variable Definitions ---                                       */

define temp-table list-action no-undo
  field action         as character format "x(15)" label "Процедура"
  field file-name      as character
  index pi is unique primary /* [word-index] */
    file-name ascending
  .

define stream UpgStream .

do
on error undo, return error return-value
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_connect      for ub._connect .
  define buffer buf_myconnection for ub._myconnection .

  define variable v-log       as logical   no-undo .
  define variable v-gen-file  as character no-undo .
  define variable v-choice    as integer   no-undo .
  define variable v-login-usr as logical   no-undo .

  find first buf_sys-ctrl no-lock .
  if p-date-actual-docs < buf_sys-ctrl.sys-date then
  do:
    return error 
      substitute("БД уже очищена на &1.~nВы можете ввести дату большую или равную текущей.",buf_sys-ctrl.sys-date).  
  end. 

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.

  assign
    v-choice    = 0
    v-login-usr = false
    v-gen-file  = "clean_db.log"
  .

  run run-load in this-procedure
    no-error .
  if error-status :error then do:
    return error return-value.
  end.
END.


PROCEDURE cre-list-action :
  do
  on error  undo, return error substitute( "&1 (cre-list-action). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-list-action). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-list-action). endkey", vss-workfile )
  :
    { utl/clean_db.i }
  end.
END PROCEDURE.


PROCEDURE run-load :
  define variable lok           as logical no-undo .
  define variable save_ab       as logical no-undo.
  define variable v-archive-ok  as logical init true  no-undo .
  define variable v-comment     as character no-undo .
  define variable v-can-print   as logical   no-undo .
    
  define buffer buf_clients for ub.clients.
  define buffer buf_db-attr for ub.db-attr.
  define buffer buf_user-login for ub.user-login.  

  on write of ub.db-attr override do: end.
    
  do
  on error  undo, return error substitute( "&1 (run-load). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (run-load). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (run-load). endkey", vss-workfile )
  :
    assign
      save_ab = SESSION :APPL-ALERT-BOXES
      SESSION :APPL-ALERT-BOXES = NO
    .
    
    /* запись информации о текуще БД в журнал */
    run write-to-log in this-procedure
      ( {&new-line} + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + {&new-line}
      ,p-handle-callback
      ).

    /* запускаем расчет архивов  */
    if buf_sys-ctrl.db-num <> 0 then
    do:
    find first buf_clients no-lock where 
               buf_clients.db-num = buf_sys-ctrl.db-num .
    run write-to-log in this-procedure
      ({&new-line} + "Расчет архивов." + {&new-line}
      ,p-handle-callback
      ).
/*run gbl/inidebug.p.*/
    find first buf_user-login no-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = {&uls-normal}
          and buf_user-login.user-login = userid.
    run rep/chk-ahz.p
      (input        buf_clients.obj-type   /* p-obj-type          */
      ,input        buf_clients.obj-code   /* p-obj-code          */
      ,input        true                   /* p-verify-detail     */
      ,input        true                   /* p-verify-arh        */
      ,input        true                   /* p-verify-ahsp       */
      ,input        true                   /* p-verify-aht        */
      ,input        true                   /* p-check-act         */
      ,input        buf_clients.db-num     /* p-check-act-db-num  */
      ,input        buf_user-login.user-id /* p-check-act-user-id */
      ,input-output p-date-actual-docs     /* p-date-start        */
      ,input-output p-date-actual-docs     /* p-date-end          */
      ,output       v-archive-ok           /* p-archive-ok        */
      ,output       v-comment              /* p-comment           */
      ,output       v-can-print            /* p-can-print         */
    ) .
    if v-archive-ok = false then
    do:
      return error "Очистка БД невозможна.~nНе удалось рассчитать архивы.~n" + v-comment.   
    end.
    end.

    /* заполняем временную таблицу, в которой заданы все действия */
    run write-to-log in this-procedure
      ({&new-line} + "Создание списка файлов для запуска." + {&new-line}
      ,p-handle-callback
      ).
    assign
      lok = session :set-wait-state("compiler")
    .
    RUN cre-list-action no-error .
    if error-status :error then do:
      return error "Ошибка при создании списка файлов! " + return-value .
    end.

    assign
      lok = session :set-wait-state("")
    .

    run write-to-log in this-procedure
       ( "Очистка БД" + {&new-line}
         + substitute( "до даты: &1",  p-date-actual-docs ) + {&new-line}
         + {&new-line}
         ,p-handle-callback
       ).
    do transaction
    on error undo, return error return-value
    on stop  undo, return error return-value
    :
      find current buf_sys-ctrl exclusive-lock .
      assign
        buf_sys-ctrl.sys-date = p-date-actual-docs.
      .
      
      find first buf_db-attr exclusive-lock
        where buf_db-attr.db-num    = buf_sys-ctrl.db-num
          and buf_db-attr.attr-code = {&attr-cut-fin-date}
        no-error .
      if not available buf_db-attr then do:
        create buf_db-attr .
        assign
          buf_db-attr.db-num    = buf_sys-ctrl.db-num
          buf_db-attr.attr-code = {&attr-cut-fin-date}
        .
      end.
      assign
        buf_db-attr.attr-value = string( p-date-actual-docs, "99/99/9999" )
      .
      release buf_db-attr.
      release buf_sys-ctrl.
    end.
    /* выполняем все действия */
    for each list-action no-lock on error undo, return error return-value :
      /* обнуляем значение, возвращаемое из процедуры */
      run clear-return-value in this-procedure .

      assign
        ttd = string(today, '99/99/9999') + " " + string(time, 'HH:MM')
      .

      /* проверяем, что файл не был удален */
      /* если это произошло, то останавливаем процедуру обрезания */
      if search( list-action.file-name ) = ? then do:
        if search( entry(1, list-action.file-name, ".":U) + ".r":U  ) = ? then do:
          run write-to-log in this-procedure
            ( ' ERROR!!! Файл: ' + list-action.file-name + ' отсутствует в версии' + {&new-line}
            ,p-handle-callback
            ).
          return error substitute( "Не найден файл &1", list-action.file-name ) .
        end.
      end.

      case list-action.action :
        when "p"
        or when "w"
        then do:
          run write-to-log in this-procedure
            ( ttd + " Util: " + list-action.file-name + "~n"
            ,p-handle-callback
            ).

          assign
            v-old-time = ETIME
          .

          /* запускаем утилиту */
          run value( list-action.file-name )
            (input p-date-actual-docs
            ,input p-handle-callback
            )
            no-error .

          if error-status :error then do:
            run write-to-log in this-procedure
              ( format-etime( ETIME - v-old-time) + " ERROR: " + SUBSTITUTE("&1", RETURN-VALUE) + {&new-line}
              ,p-handle-callback
              ).
            run write-to-log in this-procedure
              ( error-status:GET-MESSAGE( error-status:NUM-MESSAGES )
              ,p-handle-callback
              ).
            return error return-value + "Ошибка при выполнении процедуры " + SUBSTITUTE("&1", list-action.file-name) .
          end.
        end.
        otherwise do:
          return error "Неизвестное действие " + SUBSTITUTE("&1", list-action.action) + " " + SUBSTITUTE("&1", list-action.file-name) .
        end.
      end case .
      run write-to-log in this-procedure
        (format-etime( ETIME - v-old-time) + " ... Ok " + {&new-line} + SUBSTITUTE("&1", RETURN-VALUE) + {&new-line}
        ,p-handle-callback
        ).
    end.
    file-info:file-name = "clean_db.log".
    run write-to-log in this-procedure
      ( 'Чистка БД успешно завершена.' + {&new-line}
        + substitute("Лог - &1.",file-info:full-pathname) + {&new-line}
        + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + {&new-line}
      ,p-handle-callback
      ).

    assign
      session :appl-alert-boxes = save_ab
    .
  end.
END PROCEDURE.


procedure clear-return-value :

  do
  on error undo, return error
  :
    /* программа - обнуляющая значение return-value */
    return .
  end.

end procedure. /* clear-return-value */