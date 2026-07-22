using ibs.th.adm.upd.*.
using ibs.th.gbl.*.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
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
define variable v-cConnect          as character no-undo .
define variable v-fltConnect        as character no-undo .
define variable v-user-entered      as logical   no-undo init false .
define variable v-name-for-load-cfg as character no-undo .
define variable v-name-for-init-db  as character no-undo .
define variable v-fname-cfg         as character no-undo .
define variable v-err-code          as integer   no-undo .
define variable v-try-connect       as logical   no-undo init false .
define variable v-is-copy           as logical   no-undo init false .
define variable v-load-cfg          as logical      no-undo.
define variable v-vid-ok            as logical  no-undo .
DEFINE VARIABLE v-updating          as logical   no-undo init false .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-vid-descr         as character no-undo .
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-OK AUTO-GO  NO-FOCUS
     LABEL "&Ввод":L
     SIZE 10 BY 1
     BGCOLOR 15 .
DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
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
     b-OK AT ROW 8.04 COL 11.75
     name AT ROW 4.96 COL 10 COLON-ALIGNED
     password AT ROW 6.17 COL 10 COLON-ALIGNED PASSWORD-FIELD
     password_display AT ROW 6.17 COL 10 COLON-ALIGNED  PASSWORD-FIELD
     b-quit AT ROW 8.04 COL 21.88
     IMAGE-1 AT ROW 1.08 COL 1.13
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 40.13 BY 8.96.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House 16.0"
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
on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-ok in frame FRAME-A.
  end.
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
enable
  name password password_display b-ok b-quit
  with frame FRAME-A in window w-login .
  password:VISIBLE = FALSE.
assign
  session :data-entry-return = yes
.
define variable v-num-entries as integer no-undo.
define variable ind as integer no-undo.
define variable v-param as character no-undo.
define variable v-param-name as character no-undo.
define variable v-param-value as character no-undo.
define variable vAutolog as logical no-undo.
define variable v-preconnection as logical no-undo.
if SESSION:PARAMETER <> "":U
  and SESSION:PARAMETER <> ?
then do:
  assign
    v-num-entries = num-entries( SESSION:PARAMETER, ",":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, SESSION:PARAMETER, ",":U )
    .
    if num-entries( v-param, ":":U ) > 1 then do:
      assign
        v-param-name  = entry( 1, v-param, ":":U )
        v-param-value = substring( v-param, length( v-param-name ) + 2 )
      .
      case v-param-name :
        when "U":U then do:
          if vAutolog
          then
          assign
            name = v-param-value
          .
        end.
        when "P":U then do:
           if vAutolog
           then
          assign
            password = v-param-value
          .
        end.
        when "M":U then do:
        end.
        when "A":U then do:
           if v-param-value = "admsys"
           then
           vAutolog = yes.
        end.
        otherwise do:
          message
            substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
            substitute("Параметр игнорируется.") skip
            view-as alert-box information .
        end.
      end case.
    end.
    else do:
      message
        substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
        substitute("Параметр игнорируется.") skip
        view-as alert-box information .
    end.
  end.
  if name <> "":U
    and password <> "":U
  then do:
    run utl/chkstrgbl.p.
    run adm/autoinit.p ( input name
                    ,input password
                  ) no-error.
    run adm/autoconn.p no-error.
    if error-status :error then do:
      assign
        password = "":U
      .
    end.
    else do:
      assign
        v-preconnection = TRUE
      .
    end.
    run gbl/dbdiscon.p no-error.
  end.
end.
do1:
do
on error  undo, leave
on endkey undo, leave
on stop   undo, leave
:
  if lookup( '.', propath) > 0
  then do:
    define variable v-home-directory as character no-undo .
    define variable v-ind as integer   no-undo .
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
  if v-preconnection = FALSE then do:
     run enable_ui in this-procedure .
     WAIT-FOR GO OF frame FRAME-A focus name.
     assign
       name
       password .
  end.
  if v-preconnection = FALSE
  then
      run utl/chkstrgbl.p.
  v-cConnect = ibs.th.gbl.gbl-inipar:conPar.
  if v-cConnect = ?
  or trim (v-cConnect) = ""
  then do:
    v-vid-descr = substitute("Не указаны параметры подключения к БД (&1)", ibs.th.gbl.gbl-inipar:conParKeyName) .
    v-vid-param = substitute("Login=&1&2RESULT=&3&2Description=&4", name, chr(4), "101", v-vid-descr ) .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message v-vid-descr view-as alert-box error .
    undo do1, leave.
  end.
  if index(v-cConnect, '&1':u) = 0
  then do:
    v-vid-descr = substitute("В строке подключения к БД не указан комбинация символов ~&1 (&1)", ibs.th.gbl.gbl-inipar:conParKeyName) .
    v-vid-param = substitute("Login=&1&2RESULT=&3&2Description=&4", name, chr(4), "102", v-vid-descr ) .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message v-vid-descr view-as alert-box error .
    undo do1, leave.
  end.
  assign
    v-name-for-load-cfg  = "адм" + '2':U
    v-load-cfg           = false
  .
  if name = v-name-for-load-cfg
  then do:
    assign
      name     = "адм"
      v-load-cfg = true
    .
  end.
  v-fltConnect = ibs.th.gbl.gbl-inipar:conParFlt.
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
      v-vid-descr = substitute("В строке подключения к БД параметров не указана комбинация символов ~&1 (&1)", ibs.th.gbl.gbl-inipar:conParFltKeyName) .
      message v-vid-descr view-as alert-box error .
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
    ) no-error.
  if userid('ub':U) = '':U
  then do:
    def var vtext as char no-undo.
    vtext = return-value.
    v-vid-param = "Login=" + name + chr(4) + "RESULT=103" + chr(4) + "Description=Ошибка при подключении к базе данных. " + vtext.
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message
      "Ошибка при подключении к базе данных" skip
      vtext skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
  def var v-isUpdShm as logical no-undo.
  run adm/upddb.p (input v-cConnect, output v-isUpdShm) no-error.
  if error-status:error
  then do:
    message
      "Ошибка при обновлении схемы БД" skip
      return-value skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
  if v-isUpdShm
  then do:
    run gbl/dbconn.p
      (input v-cConnect
      ,input v-fltConnect
      ,input name
      ,input password
      ,input-output v-user-entered
      ) .
    if userid('ub':U) = '':U
    then do:
      v-vid-param = "Login=" + name + chr(4) + "RESULT=103" + chr(4) + "Description=Ошибка при подключении к базе данных. Неизвестный пользователь".
      run trg/video-action.p (input 50,
                              input v-vid-param,
                              output v-vid-ok,
                              output v-vid-mes) .
      message
        "Ошибка при подключении к базе данных" skip
        "Неизвестный пользователь" skip
        view-as alert-box error .
      disconnect ub no-error .
      quit.
    end.
  end.
end.
assign
  session :data-entry-return = no
.
RUN disable_UI.
if v-user-entered
then
DO2:
do
:
  run adm/unloaddb.w
    (input  name
    ,input  password
    ,output v-is-copy
    ) .
  def var v-msg as character no-undo.
  if v-is-copy = false
  then do:
    run adm/chk-db.p no-error .
    if error-status :error then do:
      v-msg = return-value.
      v-vid-param = "Login=" + name + chr(4) + "RESULT=104" + chr(4) + "Description=" + error-status :get-message(1) + ";" + v-msg .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        error-status :get-message(1) skip v-msg skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      if v-load-cfg = true then do:
        run adm/checkcnf.p
          ( input "cfg-load":U
          ) no-error .
        if error-status :error
          and error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end.
      else do:
        run adm/chkdbkey.p no-error .
        if error-status :error then do:
          v-vid-param = "Login=" + name + chr(4) + "RESULT=105" + chr(4) + "Description=Ошибка проверки кодировки ключей БД" .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
          if error-status :get-message(1) <> "" then do:
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
            ) no-error .
          if error-status :error then do:
            v-vid-param = "Login=" + name + chr(4) + "RESULT=106" + chr(4) + "Description=Ошибка проверки параметров" .
            run trg/video-action.p (input 50,
                                    input v-vid-param,
                                    output v-vid-ok,
                                    output v-vid-mes) .
            if error-status :get-message(1) <> "" then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
          end.
          else do:
            run gbl/sys-main.p
              (input name
              ,input password
              ) no-error .
            if error-status :error then do:
              v-vid-param = "Login=" + name + chr(4) + "RESULT=107" + chr(4) + "Description=" + error-status :get-message(1) .
              run trg/video-action.p (input 50,
                                    input v-vid-param,
                                    output v-vid-ok,
                                    output v-vid-mes) .
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              LEAVE DO2.
            end.
          end.
        end.
      end.
    end.
  end.
end.
else do:
  if v-try-connect = true
  then do:
     if error-status :error then do:
        v-vid-param = "Login=" + name + chr(4) + "RESULT=108" + chr(4) + "Description=Ошибка при подключении к БД. " + error-status :get-message(1) .
        run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
        message
           "Ошибка при подключении к БД" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
        disconnect ub no-error .
        quit.
     end.
     ELSE DO:
        v-vid-param = "Login=" + name + chr(4) + "RESULT=109" + chr(4) + "Description=Ошибка при подключении к БД. " + error-status :get-message(1) .
        run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
        message
           "Ошибка при подключении к базе данных" skip
           "Обратитесь к администратору" skip
           "Строка подключения к БД:" skip
           v-cConnect skip
           view-as alert-box error .
     end.
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
  ENABLE b-OK IMAGE-1 name password_display b-quit
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW w-login.
END PROCEDURE.
