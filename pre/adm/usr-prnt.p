block-level on error undo, throw.
define input parameter parParentProc   AS WIDGET-HANDLE    NO-UNDO .
define input parameter p-user-id       as character        no-undo .
define input parameter p-db-num        as integer          no-undo .
define variable vss-revision    as character no-undo init "$Revision: a26797a5baf0, 2307, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Feb 14 16:31:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-prnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/usr-prnt.p $":U .
define variable vss-description as character no-undo init "Печать прав пользователя".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer buf_user-login        for ub.user-login .
define buffer buf_user-account      for ub.user-account .
define buffer buf_global-state      for ub.global-state .
define buffer buf_global-state-attr for ub.global-state-attr .
define variable v-action-gbl as logical no-undo .
define variable g#report-num              as integer              no-undo .
define stream out-stream.
do
on error undo, return error
:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
   run get-report-num in parparentproc (output g#report-num).
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define variable v-usr-prnt-sheet1-cur-data-row     as integer      no-undo.
define variable v-usr-prnt-cell-file-name       as character    no-undo.
define variable v-usr-prnt-data-file-name       as character    no-undo.
procedure usr-prnt-init :
do
on error undo, return error
:
    assign
        v-usr-prnt-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-usr-prnt-data-file-name
    ).
    output stream excel-line to value( v-usr-prnt-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-usr-prnt-cell-file-name
    ).
    output stream excel-cell to value( v-usr-prnt-cell-file-name ).
    run usr-prnt-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Фирмы,Объекты,Меню,Права":U
    ).
   run usr-prnt-write-cell-data in this-procedure (
         input "Фирмы_valutCode":U
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input "Объекты_valutCode":U
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input "Меню_valutCode":U
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input "Права_valutCode":U
      , input "0":U
   ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Фирмы_columnList":U
        , input "firm_code,firm_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Фирмы_columnType":U
        , input "S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Фирмы_subtotalList":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Фирмы_subtotalType":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Объекты_columnList":U
        , input "obj_code,obj_type,obj_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Объекты_columnType":U
        , input "S,S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Объекты_subtotalList":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Объекты_subtotalType":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Меню_columnList":U
        , input "menu_obj,menu_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Меню_columnType":U
        , input "S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Меню_subtotalList":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Меню_subtotalType":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Права_columnList":U
        , input "actn_obj,actn_grp,actn_id,actn_name,actn_ps":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Права_columnType":U
        , input "S,S,S,S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Права_subtotalList":U
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "Права_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure usr-prnt-sheet1-write-line-data :
define input parameter p-firm-code as character        no-undo.
define input parameter p-firm-name  as character        no-undo.
do
on error undo, return error
:
      put stream excel-line unformatted
                            "Фирмы":U
            chr(9)   "DTA":U
            chr(9)   p-firm-code
            chr(9)   p-firm-name
            chr(10)
      .
end.
end procedure.
procedure usr-prnt-sheet2-write-line-data :
define input parameter p-obj-type as character        no-undo.
define input parameter p-obj-code as character        no-undo.
define input parameter p-obj-name as character        no-undo.
do
on error undo, return error
:
      put stream excel-line unformatted
                            "Объекты":U
            chr(9)   "DTA":U
            chr(9)   p-obj-type
            chr(9)   p-obj-code
            chr(9)   p-obj-name
            chr(10)
      .
end.
end procedure.
procedure usr-prnt-sheet3-write-line-data :
define input parameter p-menu_obj  as character        no-undo.
define input parameter p-menu_name as character        no-undo.
do
on error undo, return error
:
      put stream excel-line unformatted
                            "Меню":U
            chr(9)   "DTA":U
            chr(9)   p-menu_obj
            chr(9)   p-menu_name
            chr(10)
      .
end.
end procedure.
procedure usr-prnt-sheet4-write-line-data :
define input parameter p-actn-obj   as character        no-undo.
define input parameter p-actn-grp   as character        no-undo.
define input parameter p-actn-id    as character        no-undo.
define input parameter p-actn-name  as character        no-undo.
define input parameter p-actn-ps    as character        no-undo.
do
on error undo, return error
:
      put stream excel-line unformatted
                            "Права":U
            chr(9)   "DTA":U
            chr(9)   p-actn-obj
            chr(9)   p-actn-grp
            chr(9)   p-actn-id
            chr(9)   p-actn-name
            chr(9)   p-actn-ps
            chr(10)
      .
end.
end procedure.
procedure usr-prnt-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure usr-prnt-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
define variable v-template-file-name    as character    no-undo.
define variable v-vb-file-name          as character    no-undo.
define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/user.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure usr-prnt-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/user.xlt" .
        export "exe/t_form.bas" .
        export v-usr-prnt-cell-file-name.
        export v-usr-prnt-data-file-name.
    output close.
end.
end procedure.
  FIND FIRST buf_global-state
    NO-LOCK
    .
  FIND FIRST buf_global-state-attr
    WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
    AND buf_global-state-attr.attr-code = "action-gbl"
    EXCLUSIVE-LOCK
    NO-error
    .
  IF AVAILABLE buf_global-state-attr
    THEN
  DO:
    if buf_global-state-attr.attr-value = "yes" then v-action-gbl = yes .
  END.
   FIND FIRST buf_user-account
      WHERE buf_user-account.user-id = p-user-id
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_user-account
   THEN DO:
      message
         "Пользователь" p-user-id "не найден"
         skip
      view-as alert-box information.
      return.
   END.
   FIND FIRST buf_user-login
      WHERE buf_user-login.user-id = buf_user-account.user-id
         AND buf_user-login.db-num = p-db-num
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_user-login
   THEN DO:
      message
         "У пользователя" buf_user-account.nik "отсутствует логин"
         skip "для БД" p-db-num
      view-as alert-box information.
      return.
   END.
   run open-stream     IN THIS-PROCEDURE .
   run print-header    in this-procedure .
   run print-body      in this-procedure .
   run close-stream    IN THIS-PROCEDURE .
end.
procedure open-stream :
do
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
    run usr-prnt-init in this-procedure.
end.
end procedure.
PROCEDURE print-header :
do
on error undo, return error
:
    run usr-prnt-write-cell-data in this-procedure (
          input "user_id_1":U
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_name_1":U
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_nik_1":U
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_login_1":U
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_db_1":U
        , input buf_user-login.db-num
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_id_2":U
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_name_2":U
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_nik_2":U
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_login_2":U
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_db_2":U
        , input buf_user-login.db-num
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_id_3":U
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_name_3":U
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_nik_3":U
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_login_3":U
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_db_3":U
        , input buf_user-login.db-num
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_id_4":U
        , input buf_user-account.user-id
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_name_4":U
        , input buf_user-account.last-name
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_nik_4":U
        , input buf_user-account.nik
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_login_4":U
        , input buf_user-login.user-login
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input "user_db_4":U
        , input buf_user-login.db-num
    ).
end.
END PROCEDURE.
PROCEDURE print-body :
  define buffer buf_user-login-action-role for ub.user-login-action-role .
  define buffer buf_action-role-item       for ub.action-role-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_action-role            for ub.action-role .
  define buffer buf_user-host              for ub.user-host .
  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_user-menu-group        for ub.user-menu-group .
  define buffer buf_clients                for ub.clients .
  define buffer buf_menu-group             for ub.menu-group .
  define variable v-host-code like ub.user-host.host-code no-undo .
  define variable v-obj-code  like ub.user-obj.obj-code no-undo .
  define variable v-obj-type  like ub.user-obj.obj-type no-undo .
  do
    on error undo, return error
    :
    FOR EACH  buf_user-host WHERE
      buf_user-host.user-id = p-user-id
      NO-LOCK:
      if not v-action-gbl and buf_user-host.db-num  <> p-db-num then next .
      for FIRST buf_clients
        WHERE buf_clients.obj-type = 'орг':U
        AND buf_clients.obj-code = buf_user-host.host-code
        NO-LOCK
        :
        RUN usr-prnt-sheet1-write-line-data IN THIS-PROCEDURE
          ( INPUT buf_user-host.host-code
          , INPUT buf_clients.obj-name
          ) .
          v-host-code = buf_user-host.host-code .
      end.
    END.
    FOR EACH  buf_user-obj where
      buf_user-obj.user-id = p-user-id
      NO-LOCK:
      if not v-action-gbl and buf_user-obj.db-num  <> p-db-num then next .
      for FIRST buf_clients
        WHERE buf_clients.obj-type = buf_user-obj.obj-type
        AND buf_clients.obj-code = buf_user-obj.obj-code
        NO-LOCK
        :
        RUN usr-prnt-sheet2-write-line-data IN THIS-PROCEDURE
          ( INPUT buf_user-obj.obj-type
          , INPUT buf_user-obj.obj-code
          , INPUT buf_clients.obj-name
          ) .
          assign
            v-obj-code = buf_user-obj.obj-code
            v-obj-type = buf_user-obj.obj-type
          .
      END.
    end.
    FOR EACH  buf_user-menu-group
      WHERE buf_user-menu-group.user-id = p-user-id
      NO-LOCK
      ,
      each buf_menu-group
      WHERE buf_menu-group.menu-code        = buf_user-menu-group.menu-code
      AND buf_menu-group.menu-group-code  = buf_user-menu-group.menu-group-code
      :
      if not v-action-gbl and buf_user-menu-group.db-num  <> p-db-num then next .
      CASE buf_user-menu-group.menu-group-context:
        WHEN 'global':U
        THEN
          DO:
            RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
              ( INPUT "Глобально"
              , INPUT buf_menu-group.menu-group-name
              ) .
          END.
        WHEN 'firm':U
        THEN
          DO:
            FIND  FIRST buf_clients
              WHERE buf_clients.obj-type = 'орг':U
              AND buf_clients.obj-code = buf_user-menu-group.host-code
              NO-LOCK
              NO-ERROR
              .
            IF AVAILABLE buf_clients
              THEN
            DO:
              RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
                ( INPUT SUBSTITUTE( "Фирма &1 &2", buf_clients.obj-code, buf_clients.obj-name)
                , INPUT buf_menu-group.menu-group-name
                ) .
            END.
          END.
        WHEN 'object':U
        THEN
          DO:
            FIND  FIRST buf_clients
              WHERE buf_clients.obj-type = buf_user-menu-group.obj-type
              AND buf_clients.obj-code = buf_user-menu-group.obj-code
              NO-LOCK
              NO-ERROR
              .
            IF AVAILABLE buf_clients
              THEN
            DO:
              RUN usr-prnt-sheet3-write-line-data IN THIS-PROCEDURE
                ( INPUT SUBSTITUTE( "&1 &2 &3", buf_clients.obj-type, buf_clients.obj-code, buf_clients.obj-name)
                , INPUT buf_menu-group.menu-group-name
                ) .
            END.
          END.
        OTHERWISE
        DO:
        END.
      END CASE.
    END.
    if v-action-gbl then
    do:
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.action-role-context = 'global':U
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT "Без привязки"
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.action-role-context = 'firm':U
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("Фирма &1", buf_user-login-action-role.host-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.action-role-context = 'object':U
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
    end.
    else
    do:
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = 'global':U
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT "Без привязки"
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = 'firm':U
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("Фирма &1", buf_user-login-action-role.host-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
      FOR EACH buf_user-login-action-role
        WHERE buf_user-login-action-role.action-head-code    = 0
        AND buf_user-login-action-role.db-num              = p-db-num
        AND buf_user-login-action-role.action-role-context = 'object':U
        AND buf_user-login-action-role.user-id             = p-user-id
        NO-LOCK
        ,
        FIRST buf_action-role
        WHERE buf_action-role.action-head-code    = 0
        AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
        AND buf_action-role.db-num              = p-db-num
        NO-LOCK
        :
        FOR EACH  buf_action-role-item
          WHERE buf_action-role-item.action-head-code    = 0
          AND buf_action-role-item.action-role-code    = buf_user-login-action-role.action-role-code
          AND buf_action-role-item.db-num              = p-db-num
          NO-LOCK
          ,
          FIRST buf_action-item
          WHERE buf_action-item.action-head-code    = 0
          AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
          :
          RUN usr-prnt-sheet4-write-line-data IN THIS-PROCEDURE
            ( INPUT SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code)
            , INPUT buf_action-role.action-role-name
            , INPUT buf_action-item.action-item-code
            , INPUT buf_action-item.action-item-name
            , INPUT buf_action-item.action-item-description
            ) .
        END.
      END.
    end.
  end.
END PROCEDURE.
procedure close-stream :
do
on error undo, return error
:
    run usr-prnt-close in this-procedure .
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
    .
if session :set-wait-state( "" ) then.
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 20
        , input string(session :temp-directory) + "rpt" + string( g#report-num )
        , input 7
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
end procedure.
