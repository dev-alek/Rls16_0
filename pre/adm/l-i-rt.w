define variable vss-revision    as character no-undo init "$Revision: 21e3183bea69, 738, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Mon Aug 01 17:35:56 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: l-i-rt.w $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/l-i-rt.w $":U .
define variable vss-description as character no-undo init "Окно входа в систему".
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
define variable v-cConnect          as character no-undo .
define variable v-fltConnect        as character no-undo .
define variable v-user-entered      as logical   no-undo init false .
define variable v-name-for-load-cfg as character no-undo .
define variable v-name-for-init-db  as character no-undo .
define variable v-fname-cfg         as character no-undo .
define variable v-err-code          as integer   no-undo .
define variable v-try-connect       as logical   no-undo init false .
define variable v-is-copy           as logical   no-undo init false .
define variable v-updating          as logical   no-undo init false .
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE IMAGE IMAGE-1
     FILENAME "cmp/ith.bmp":U
     SIZE 40 BY 8.88.
DEFINE FRAME FRAME-A
     name AT ROW 4.96 COL 10 COLON-ALIGNED
     password AT ROW 6.17 COL 10 COLON-ALIGNED BLANK
     password_display AT ROW 6.17 COL 10 COLON-ALIGNED  PASSWORD-FIELD
     b-OK AT ROW 8 COL 11.75
     b-quit AT ROW 8 COL 21.88
     IMAGE-1 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 40.13 BY 9.13.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "TH Обмен с радиотерминалом"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 9.13
         WIDTH              = 40.25
         MAX-HEIGHT         = 35.63
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 35.63
         VIRTUAL-WIDTH      = 160
         RESIZE             = no
         SCROLL-BARS        = yes
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE w-login = CURRENT-WINDOW.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.
ON VALUE-CHANGED OF password_display IN FRAME FRAME-A DO:
    IF NOT v-updating THEN DO:
        ASSIGN password:SCREEN-VALUE = password_display:SCREEN-VALUE.
    END.
END.
ON ANY-KEY OF password_display IN FRAME FRAME-A DO:
    IF LASTKEY = KEY-CODE("CTRL-V") THEN DO:
           ASSIGN
           v-updating = TRUE
           password:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           password_display:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           v-updating = FALSE.
           System.Windows.Forms.Clipboard:Clear().
           RETURN NO-APPLY.
    END.
END.
ON CHOOSE OF b-OK IN FRAME FRAME-A
DO:
  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
END.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame FRAME-A
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
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
on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then apply "CHOOSE" to b-ok in frame FRAME-A.
end.
on window-close of w-login do:
  apply "end-error" to frame FRAME-A.
end.
ASSIGN
  CURRENT-WINDOW             = w-login
  SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
  session:three-d = yes
.
PAUSE 0 BEFORE-HIDE.
if session:date-format <> "dmy":U
  or session:numeric-decimal-point <> ".":U
  or session:numeric-separator <> ",":U
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неправильные установки сессии progress!" skip
    "Формат даты должен быть - " "'dmy'":U skip
    "Десятичный разделитель - " "'.'":U skip
    "Разделитель тысяч - " "','":U skip
    view-as alert-box error .
  quit.
end.
IMAGE-1 :load-image("cmp/ith.bmp") .
define variable v-auto-start  as logical   no-undo .
define variable v-num-entries as integer   no-undo .
define variable v-ind         as integer   no-undo .
define variable v-param       as character no-undo .
if  session :parameter <> "":u
and session :parameter <> ?
then do:
  assign
    v-auto-start = true
  .
  assign
    v-num-entries = num-entries( session:parameter, ",":u )
  .
  do v-ind = 1 to v-num-entries :
    assign
      v-param = entry( v-ind, SESSION:PARAMETER, ",":U )
    .
    if num-entries( v-param, ":":U ) = 2 then do:
      if v-param begins "U:" then do:
        assign
          name = entry( 2, v-param, ":":U )
        .
      end.
      if v-param begins "P:" then do:
        assign
          password = entry( 2, v-param, ":":U )
        .
      end.
    end.
  end.
end.
else do:
  assign
    v-auto-start = false
  .
  enable
    name password b-ok b-quit
    with frame FRAME-A in window w-login .
  assign
    session :data-entry-return = yes
  .
end.
run gbl/font-chk.p no-error .
if error-status :error
then do:
  message
    "Неправильные установки системных шрифтов" skip
    "Обратитесь к администратору" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box information .
end.
do1:
do
on error  undo, leave
on endkey undo, leave
on stop   undo, leave
:
  if lookup( '.', propath) > 0
  then do:
    define variable v-home-directory      as character no-undo .
    define variable v-num-entries-propath as integer   no-undo .
    define variable v-old-propath         as character no-undo .
    define variable v-new-propath         as character no-undo .
    define variable v-path-item           as character no-undo .
    assign
      file-info :file-name = '.'
      v-home-directory = file-info :full-pathname
    .
    assign
      v-old-propath = propath
      v-new-propath = ''
    .
    assign
      v-num-entries-propath = num-entries(v-old-propath)
    .
    do v-ind = 1 to v-num-entries-propath
    :
      assign
        v-path-item = entry(v-ind, v-old-propath)
      .
      if v-path-item = '.'
      then do:
        assign
          v-path-item = v-home-directory
        .
      end.
      assign
        v-new-propath = v-new-propath
                      + (if v-new-propath <> '' then ',' else '')
                      + v-path-item
      .
    end.
    assign
      propath = v-new-propath
    .
  end.
  run enable_ui in this-procedure .
  if v-auto-start <> true
  then do:
    WAIT-FOR GO OF frame FRAME-A focus name.
    assign
      name
      password .
  end.
  GET-KEY-VALUE SECTION "REP-SETS" KEY "ConPar" VALUE v-cConnect.
  if v-cConnect = ?
  or trim (v-cConnect) = ""
  then do:
    message
      "Не указаны параметры подключения к БД"
      "(секция REP-SETS ключ ConPar в .ini файле)."
      view-as alert-box error .
    undo do1, leave.
  end.
  if index(v-cConnect, '&1':u) = 0
  then do:
    message
      "В строке подключения к БД не указан комбинация символов &1"
      "(секция REP-SETS ключ ConPar в .ini файле)."
      view-as alert-box error .
    undo do1, leave.
  end.
  GET-KEY-VALUE SECTION "REP-SETS":U KEY "ConParFlt":U VALUE v-fltConnect .
  if trim (v-fltConnect) = "":U
    or trim( v-fltConnect ) = trim( v-cConnect )
  then do:
    assign
      v-fltConnect = ?
    .
  end.
  else do:
    if index(v-fltConnect, '&1':u) = 0
    then do:
      message
        "В строке подключения к БД параметров не указана комбинация символов &1"
        "(секция REP-SETS ключ ConParFlt в .ini файле)."
        view-as alert-box error .
      undo do1, leave.
    end.
  end.
  assign
    v-try-connect = true
  .
  run gbl/dbconn.p
    (input v-cConnect
    ,input v-fltConnect
    ,input name
    ,input password
    ,input-output v-user-entered
    ) .
  if userid('ub':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
end.
assign
  session :data-entry-return = no
.
RUN disable_UI.
if v-user-entered
then do:
  run adm/unloaddb.w
    ( input name
     ,input password
     ,output v-is-copy
    ).
  if v-is-copy = false
  then do:
    run adm/chkdbkey.p no-error.
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    else do:
      run adm/checkcnf.p
        ( input "cfg-check":U
        ) no-error.
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end.
      else do:
        run gbl/w-reqsrv.w
          (input name
          ,input password
          ,input v-auto-start
          ).
      end.
    end.
  end.
end.
else do:
  if v-try-connect = true
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Обратитесь к администратору" skip
      "Строка подключения к БД:" skip
      v-cConnect skip
      view-as alert-box error .
  end.
end.
disconnect ub no-error .
quit.
PROCEDURE ARM-users :
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
  THEN DELETE WIDGET w-login.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE IMAGE-1 name password password_display b-OK b-quit
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW w-login.
END PROCEDURE.
