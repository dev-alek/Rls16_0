block-level on error undo, throw.
define input parameter p-cut-type            as integer   no-undo .
define input parameter p-db-list             as character no-undo .
define input parameter p-date-actual-goods   as date      no-undo .
define input parameter p-date-actual-docs    as date      no-undo .
define input parameter p-date-actual-findoc  as date      no-undo .
define input parameter p-date-output-zone    as date      no-undo.
define input parameter p-stay-recipe-goods   as logical   no-undo .
define input parameter p-stay-weight-goods   as logical   no-undo .
define input parameter p-not-copy-del-goods  as logical   no-undo .
define input parameter p-stay-history        as logical   no-undo .
define input parameter p-handle-callback     as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cutld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cutld.p $":U .
define variable vss-description as character no-undo init "Автоматический upgrade базы данных".
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
    output stream LogStream to "cut-load.log" page-size 0 append.
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
define new shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
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
    and trim( buf_sys-ctrl.status_ ) <> 'sttsDB-cutld':u
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
      buf_sys-ctrl.status_ = 'sttsDB-cutld':u
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
            ( input substitute( "&1 &2 В системе работают пользователи:&3", string(today, '99/99/9999'), string(time, 'HH:MM:SS'), chr(10) )
            ).
        end.
        run callback-write-to-log in p-handle-callback
          ( input substitute( "&1 &2 &3&4", buf_connect._connect-usr, buf_connect._connect-name, buf_connect._connect-device, chr(10) )
          ).
      end.
    end.
    if v-login-usr = true then do:
            run gbl/d-askw.w
        ( input "Усечение БД"
          ,input substitute("Для выполнения усечения БД необходимо, чтобы не было запущено ни одной сессии.&1" +                                   "Для продолжения работы ВЫКЛЮЧИТЕ ВСЕ работающие сессии и затeм нажмите <ПРОДОЛЖИТЬ>&1" +                                   "или нажмите <ВЫЙТИ> и попробуйте зайти в систему позднее"                                   , chr(10))
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
  end.
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
  on error  undo, return error substitute( "&1 (cre-list-action). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-list-action). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-list-action). endkey", vss-workfile )
  :
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00000001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00000005.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00000010.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00001000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00007000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00008000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00012000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00013000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00014000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00019000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00025000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00037000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00037001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00038000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00043000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00043001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00043002.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00044000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00044001.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00044002.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00045000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00046000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00049000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00055000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00061000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00067000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00073000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00075000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00079000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00080000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00090000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00091000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00104000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00105000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00106000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00108000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00109000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00111000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00127000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00128000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00133000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00139000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00145000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00151000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00157000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00163000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00169000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00175000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00176000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00181000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00187000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00193000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00194000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00195000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00196000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00198000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00199000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00200000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00205000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00206000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00207000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00210000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00215000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00216000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00217000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00218000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00220000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00221000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00230000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00240000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00250000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00994000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00995000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00996000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00997000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00998000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/00999000.p'
  .
create list-action .
assign
  list-action.action    = 'p'
  list-action.file-name = 'cut/99999999.p'
  .
  end.
END PROCEDURE.
PROCEDURE run-load :
  do
  on error  undo, return error substitute( "&1 (run-load). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
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
          ( substitute( "БД не готова к обрезанию! &1&2", return-value, chr(10) )
           ,p-handle-callback
          ).
        return error  .
      end.
    end.
    assign
      save_ab = SESSION :APPL-ALERT-BOXES
      SESSION :APPL-ALERT-BOXES = NO
    .
    run utl/cutl-inf.p .
    run write-to-log in this-procedure
      ( chr(10) + string(today, '99/99/9999') + " " + string(time, 'HH:MM') + chr(10)
                      + SUBSTITUTE("&1", RETURN-VALUE) + chr(10)
      ,p-handle-callback
      ).
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
    case p-cut-type :
      when 0 then do:
        run write-to-log in this-procedure
          ( "Полное усечение БД" + chr(10)
            + substitute( "Дата актуальности складских документов и архивов: &1",  p-date-actual-docs ) + chr(10)
            + substitute( "Дата актуальности финансовых документов и архивов: &1",  p-date-actual-findoc ) + chr(10)
            + substitute( "Дата актуальности товаров: &1",  p-date-actual-goods ) + chr(10)
            + substitute( "Дата расходной зоны: &1",  p-date-output-zone ) + chr(10)
            + substitute( "Не копировать удаленные товары с ненулевыми остатками: &1",  p-not-copy-del-goods ) + chr(10)
            + substitute( "Переносить историю по всем таблицам: &1",  p-stay-history ) + chr(10)
            + substitute( "Оставить товары для рецептов: &1",  p-stay-recipe-goods ) + chr(10)
            + substitute( "Оставить все весовые товары: &1",  p-stay-weight-goods ) + chr(10)
            + chr(10)
            ,p-handle-callback
          ).
      end.
      when 1 then do:
        run write-to-log in this-procedure
          ( substitute( "Усечение документов в ГБД по БД &1", p-db-list ) + chr(10)
            + substitute( "Дата актуальности складских документов и архивов: &1",  p-date-actual-docs ) + chr(10)
            + substitute( "Дата актуальности финансовых документов и архивов: &1",  p-date-actual-findoc ) + chr(10)
            + chr(10)
            ,p-handle-callback
          ).
        assign
          v-num-entries = num-entries( p-db-list, chr(44) )
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
            ( ttd + " Utl: " + list-action.file-name + " "
            ,p-handle-callback
            ).
          assign
            v-old-time = ETIME
          .
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
        (format-etime( ETIME - v-old-time) + " ... Ok " + SUBSTITUTE("&1", RETURN-VALUE) + chr(10)
        ,p-handle-callback
        ).
    end.
    run write-to-log in this-procedure
      ( '"Обрезание" БД успешно завершено.' + chr(10)
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
