block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cutld.p $
$Archive: utl/cutld.p $

Автоматический upgrade базы данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

/* Parameters Definitions ---                                           */

define input parameter p-cut-type            as integer   no-undo . /* 0 - полное, 1 - документы в ГБД */
define input parameter p-db-list             as character no-undo . /* заполнено при p-cut-type = 1 */
define input parameter p-date-actual-goods   as date      no-undo .
define input parameter p-date-actual-docs    as date      no-undo .
define input parameter p-date-actual-findoc  as date      no-undo .
define input parameter p-date-output-zone    as date      no-undo.
define input parameter p-stay-recipe-goods   as logical   no-undo .
define input parameter p-stay-weight-goods   as logical   no-undo .
define input parameter p-not-copy-del-goods  as logical   no-undo .
define input parameter p-stay-history        as logical   no-undo .
define input parameter p-handle-callback     as handle    no-undo . /* вопросительный знак или указатель на вызываемую процедуру */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cutld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cutld.p $":U .
define variable vss-description as character no-undo init "Автоматический upgrade базы данных".
{ cmp/str-glbl.i }
{ utl/cut-load.i }
{ utl/tt-objs.i new }

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
  define buffer dst_sys-ctrl for dst.sys-ctrl .
  define buffer buf_connect      for ub._connect .
  define buffer buf_myconnection for ub._myconnection .

  define variable v-log       as logical   no-undo .
  define variable v-gen-file  as character no-undo .
  define variable v-choice    as integer   no-undo .
  define variable v-login-usr as logical   no-undo .

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.

  find first buf_sys-ctrl .
  if trim( buf_sys-ctrl.status_ ) <> "":U
    and trim( buf_sys-ctrl.status_ ) <> {&sttsDB-cutld}
  then do:
    message
      substitute( "При статусе БД равном &1 усечение не допускается!", buf_sys-ctrl.status_ ) skip
      view-as alert-box error .
    undo, return error .
  end.

  do transaction
  on error undo, return error return-value
  on stop  undo, return error return-value
  :
    find first buf_sys-ctrl exclusive-lock .
    assign
      buf_sys-ctrl.status_ = {&sttsDB-cutld}
    .
    release buf_sys-ctrl.
  end.
  assign
    v-choice    = 0
    v-login-usr = false
  .
  block_working:
  do while v-choice <> 2
  on error undo, return error return-value
  :
    find first buf_myconnection .
    for each buf_connect
    on error undo, return error return-value
    :
      if ( buf_connect._connect-type = "REMC":U
            or buf_connect._connect-type = "SELF":U
          )
          and
          ( buf_connect._connect-pid <> buf_myconnection._Myconn-pid
            or buf_connect._connect-usr <> buf_myconnection._Myconn-userid
          )
      then do:
        if v-login-usr = false then do:
          assign
            v-login-usr = true
          .
          run callback-write-to-log in p-handle-callback
            ( input substitute( "&1 &2 В системе работают пользователи:&3", string(today, '99/99/9999'), string(time, 'HH:MM:SS'), {&new-line} )
            ).
        end.
        run callback-write-to-log in p-handle-callback
          ( input substitute( "&1 &2 &3&4", buf_connect._connect-usr, buf_connect._connect-name, buf_connect._connect-device, {&new-line} )
          ).
      end.
    end. /*for each buf_connect:*/

    if v-login-usr = true then do:
      &scop my-message substitute("Для выполнения усечения БД необходимо, чтобы не было запущено ни одной сессии.&1" + ~
                                  "Для продолжения работы ВЫКЛЮЧИТЕ ВСЕ работающие сессии и затeм нажмите <ПРОДОЛЖИТЬ>&1" + ~
                                  "или нажмите <ВЫЙТИ> и попробуйте зайти в систему позднее" ~
                                  , ~{&new-line~})
      run gbl/d-askw.w
        ( input "Усечение БД"
          ,input {&my-message}
          ,input "|"
          ,input "Продолжить|Выйти"
          ,input "|"
          ,input 1
          ,input 2
          ,output v-choice
        ).
      if v-choice = 2 then do:
        do transaction
        on error undo, return error return-value
        on stop  undo, return error return-value
        :
          find first buf_sys-ctrl exclusive-lock .
          assign
            buf_sys-ctrl.status_ = "":U
          .
          release buf_sys-ctrl.
        end.
        return error .
      end.
      assign
        v-login-usr = false
      .
    end.
    else do:
      leave block_working .
    end.
  end. /*do while v-choice <> 2  :*/

  run run-load in this-procedure
    no-error .
  if error-status :error then do:
    message
      "Ошибка при выполнении процедуры run-load" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error return-value.
  end.
  do transaction
  on error undo, return error return-value
  on stop  undo, return error return-value
  :
    find first buf_sys-ctrl exclusive-lock .
    assign
      buf_sys-ctrl.status_ = "":U
    .
    release buf_sys-ctrl.

    find first dst_sys-ctrl exclusive-lock .
    assign
      dst_sys-ctrl.status_ = "":U
    .
    release dst_sys-ctrl.
  end.
END.


PROCEDURE cre-list-action :
  do
  on error  undo, return error substitute( "&1 (cre-list-action). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-list-action). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-list-action). endkey", vss-workfile )
  :
    { utl/cutld.i }
  end.
END PROCEDURE.


PROCEDURE run-load :
  do
  on error  undo, return error substitute( "&1 (run-load). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (run-load). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (run-load). endkey", vss-workfile )
  :
    define variable lok           as logical no-undo .
    define variable save_ab       as logical no-undo.
    define variable v-num-entries as integer no-undo .
    define variable v-ind         as integer no-undo .
    define variable v-db-num      as integer no-undo .

    define buffer buf_clients for ub.clients .

    if p-cut-type = 1 then do:
      run utl/chk-btpr.p
        ( input p-cut-type
         ,input p-db-list
         ,output lok
        ).
      if lok <> true then do:
        run write-to-log in this-procedure
          ( substitute( "БД не готова к обрезанию! &1&2", return-value, {&new-line} )
           ,p-handle-callback
          ).
        return error  .
      end.
    end.

    assign
      save_ab = SESSION :APPL-ALERT-BOXES
      SESSION :APPL-ALERT-BOXES = NO
    .
    /* получение информации о текущей БД */
    run utl/cutl-inf.p .
    /* запись информации о текуще БД в журнал */
    run write-to-log in this-procedure
      ( {&new-line} + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + {&new-line}
                      + SUBSTITUTE("&1", RETURN-VALUE) + {&new-line}
      ,p-handle-callback
      ).

    /* заполняем временную таблицу в которой заданы все действия */
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

    case p-cut-type :
      when 0 then do:
        run write-to-log in this-procedure
          ( "Полное усечение БД" + {&new-line}
            + substitute( "Дата актуальности складских документов и архивов: &1",  p-date-actual-docs ) + {&new-line}
            + substitute( "Дата актуальности финансовых документов и архивов: &1",  p-date-actual-findoc ) + {&new-line}
            + substitute( "Дата актуальности товаров: &1",  p-date-actual-goods ) + {&new-line}
            + substitute( "Дата расходной зоны: &1",  p-date-output-zone ) + {&new-line}
            + substitute( "Не копировать удаленные товары с ненулевыми остатками: &1",  p-not-copy-del-goods ) + {&new-line}
            + substitute( "Переносить историю по всем таблицам: &1",  p-stay-history ) + {&new-line}
            + substitute( "Оставить товары для рецептов: &1",  p-stay-recipe-goods ) + {&new-line}
            + substitute( "Оставить все весовые товары: &1",  p-stay-weight-goods ) + {&new-line}
            + {&new-line}
            ,p-handle-callback
          ).
      end.
      when 1 then do:
        run write-to-log in this-procedure
          ( substitute( "Усечение документов в ГБД по БД &1", p-db-list ) + {&new-line}
            + substitute( "Дата актуальности складских документов и архивов: &1",  p-date-actual-docs ) + {&new-line}
            + substitute( "Дата актуальности финансовых документов и архивов: &1",  p-date-actual-findoc ) + {&new-line}
            + {&new-line}
            ,p-handle-callback
          ).
        assign
          v-num-entries = num-entries( p-db-list, {&comma-char} )
        .
        do v-ind = 1 to v-num-entries
        on error undo, return error substitute( "Ошибка при создании списка объектов. &1", error-status:GET-MESSAGE( error-status:NUM-MESSAGES ) )
        :
          assign
            v-db-num = integer( entry( v-ind, p-db-list ) )
          .
          for each buf_clients no-lock
            where buf_clients.db-num = v-db-num
          on error undo, return error substitute( "&1", error-status:GET-MESSAGE( error-status:NUM-MESSAGES ) )
          :
            create tt-objs .
            assign
              tt-objs.obj-type = buf_clients.obj-type
              tt-objs.obj-code = buf_clients.obj-code
            .
          end.
        end.
      end.
      otherwise do:
        return error substitute( "Неизвестный тип усечения '&1'", p-cut-type ).
      end.
    end case.

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
            ( ttd + " Utl: " + list-action.file-name + " "
            ,p-handle-callback
            ).

          assign
            v-old-time = ETIME
          .

          /* запускаем утилиту */
          run value( list-action.file-name )
            ( input p-cut-type
             ,input p-db-list
             ,input p-date-actual-goods
             ,input p-date-actual-docs
             ,input p-date-actual-findoc
             ,input p-date-output-zone
             ,input p-stay-recipe-goods
             ,input p-stay-weight-goods
             ,input p-not-copy-del-goods
             ,input p-stay-history
             ,input v-gen-file
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
        (format-etime( ETIME - v-old-time) + " ... Ok " + SUBSTITUTE("&1", RETURN-VALUE) + {&new-line}
        ,p-handle-callback
        ).
    end.
    run write-to-log in this-procedure
      ( '"Обрезание" БД успешно завершено.' + {&new-line}
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