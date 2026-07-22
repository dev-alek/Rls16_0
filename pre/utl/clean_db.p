block-level on error undo, throw.
define input parameter p-date-actual-docs    as date      no-undo .
define input parameter p-handle-callback     as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 10/07/2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clean_db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/clean_db.p $":U .
define variable vss-description as character no-undo init "Чистка базы данных до даты".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define stream LogStream .
define variable ttd        as character no-undo .
define variable v-old-time as int64     no-undo .
PROCEDURE write-to-log :
  define input parameter p-msg-str   as character no-undo .
  define input parameter p-call-back as handle    no-undo .
  do
  on error undo, return error
  :
    output stream LogStream to "clean_db.log" page-size 0 append.
    put stream LogStream unformatted p-msg-str .
    output stream LogStream close.
    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
    then do:
      run callback-write-to-log in p-call-back
        (input p-msg-str
        ) no-error .
    end.
  end.
END PROCEDURE.
FUNCTION format-etime RETURNS CHARACTER
(INPUT p-etime AS INT64  )
:
  if p-etime = ?
  then do:
    return "?????????????" .
  end.
  assign
    p-etime = p-etime / 1000
  .
  return
    string( p-etime, '->>>>>>>9')
    + ' '
    + string( p-etime, 'HH:MM:SS')
  .
END FUNCTION.
define temp-table list-action no-undo
  field action         as character format "x(15)" label "Процедура"
  field file-name      as character
  index pi is unique primary
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
  on error  undo, return error substitute( "&1 (cre-list-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-list-action). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-list-action). endkey", vss-workfile )
  :
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00037000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00037001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00043000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00043001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00045000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00055000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00061000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00090000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00091000.p'
  .
if can-find(first _File where _file._file-name = "order-doc") then
do:
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00127000.p'
  .
end.
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00169000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00193000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00199000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00217000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00221000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00230000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00240000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/00994000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01000000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01010000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01020000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cleandb/01030000.p'
  .
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
  on error  undo, return error substitute( "&1 (run-load). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (run-load). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (run-load). endkey", vss-workfile )
  :
    assign
      save_ab = SESSION :APPL-ALERT-BOXES
      SESSION :APPL-ALERT-BOXES = NO
    .
    run write-to-log in this-procedure
      ( chr(10) + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + chr(10)
      ,p-handle-callback
      ).
    if buf_sys-ctrl.db-num <> 0 then
    do:
    find first buf_clients no-lock where
               buf_clients.db-num = buf_sys-ctrl.db-num .
    run write-to-log in this-procedure
      (chr(10) + "Расчет архивов." + chr(10)
      ,p-handle-callback
      ).
    find first buf_user-login no-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = 0
          and buf_user-login.user-login = userid.
    run rep/chk-ahz.p
      (input        buf_clients.obj-type
      ,input        buf_clients.obj-code
      ,input        true
      ,input        true
      ,input        true
      ,input        true
      ,input        true
      ,input        buf_clients.db-num
      ,input        buf_user-login.user-id
      ,input-output p-date-actual-docs
      ,input-output p-date-actual-docs
      ,output       v-archive-ok
      ,output       v-comment
      ,output       v-can-print
    ) .
    if v-archive-ok = false then
    do:
      return error "Очистка БД невозможна.~nНе удалось рассчитать архивы.~n" + v-comment.
    end.
    end.
    run write-to-log in this-procedure
      (chr(10) + "Создание списка файлов для запуска." + chr(10)
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
       ( "Очистка БД" + chr(10)
         + substitute( "до даты: &1",  p-date-actual-docs ) + chr(10)
         + chr(10)
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
          and buf_db-attr.attr-code = 'cut-fin-date':U
        no-error .
      if not available buf_db-attr then do:
        create buf_db-attr .
        assign
          buf_db-attr.db-num    = buf_sys-ctrl.db-num
          buf_db-attr.attr-code = 'cut-fin-date':U
        .
      end.
      assign
        buf_db-attr.attr-value = string( p-date-actual-docs, "99/99/9999" )
      .
      release buf_db-attr.
      release buf_sys-ctrl.
    end.
    for each list-action no-lock on error undo, return error return-value :
      run clear-return-value in this-procedure .
      assign
        ttd = string(today, '99/99/9999') + " " + string(time, 'HH:MM')
      .
      if search( list-action.file-name ) = ? then do:
        if search( entry(1, list-action.file-name, ".":U) + ".r":U  ) = ? then do:
          run write-to-log in this-procedure
            ( ' ERROR!!! Файл: ' + list-action.file-name + ' отсутствует в версии' + chr(10)
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
          run value( list-action.file-name )
            (input p-date-actual-docs
            ,input p-handle-callback
            )
            no-error .
          if error-status :error then do:
            run write-to-log in this-procedure
              ( format-etime( ETIME - v-old-time) + " ERROR: " + SUBSTITUTE("&1", RETURN-VALUE) + chr(10)
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
        (format-etime( ETIME - v-old-time) + " ... Ok " + chr(10) + SUBSTITUTE("&1", RETURN-VALUE) + chr(10)
        ,p-handle-callback
        ).
    end.
    file-info:file-name = "clean_db.log".
    run write-to-log in this-procedure
      ( 'Чистка БД успешно завершена.' + chr(10)
        + substitute("Лог - &1.",file-info:full-pathname) + chr(10)
        + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + chr(10)
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
    return .
  end.
end procedure.
